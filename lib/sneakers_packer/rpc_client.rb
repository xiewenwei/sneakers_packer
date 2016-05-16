module SneakersPacker
  class RpcClient

    attr_reader :reply_queue
    attr_reader :client_lock, :request_hash

    def initialize(publisher)
      @publisher = publisher
      channel, exchange = fetch_channel_and_exchange
      @queue_name = "rpc.#{SecureRandom.uuid}"
      @consumer = build_reply_queue(channel, exchange)

      @client_lock = Mutex.new
      @request_lock = Mutex.new
      @request_hash = {}
    end

    # call remote service via rabbitmq rpc
    # @param name route_key for service
    # @param message
    # @param options{timeout} [int] timeout. seconds.   optional
    # @return result of service
    # @raise RemoteCallTimeoutError if timeout
    def call(request, options = {})
      ensure_reply_queue!

      add_request(request)

      @exchange.publish(request.message,
                        routing_key:    request.name,
                        correlation_id: request.call_id,
                        reply_to:       @reply_queue.name)

      timeout = (options[:timeout] || SneakersPacker.conf.rpc_timeout).to_i

      client_lock.synchronize { request.condition.wait(client_lock, timeout) }

      remove_request(request)

      if request.processed?
        request.response
      else
        raise RemoteCallTimeoutError, "Remote call timeouts.Exceed #{timeout} seconds."
      end
    end

    private

    def add_request(request)
      @request_lock.synchronize { @request_hash[request.call_id] = request }
    end

    def remove_request(request)
      @request_lock.synchronize { @request_hash.delete request.call_id }
    end

    def ensure_reply_queue!
      reconnected = false
      channel = nil
      exchange = nil

      @publisher.instance_eval do
        if @bunny.nil? || !@bunny.automatically_recover?
          # ensure_connection connection first
          @mutex.synchronize do
            unless connected?
              ensure_connection!
              reconnected = true
              channel = @channel
              exchange = @exchange
            end
          end
        end
      end

      # rebuid reply_queue when reconnecting occur
      if reconnected
        @consumer = build_reply_queue(channel, exchange)
      end
    end

    def build_reply_queue(channel, exchange)
      @channel, @exchange = channel, exchange

      @reply_queue    = channel.queue(@queue_name, exclusive: true)
      @reply_queue.bind(exchange, routing_key: @reply_queue.name)

      that       = self

      @reply_queue.subscribe(manual_ack: false) do |delivery_info, properties, payload|
        request = that.request_hash.fetch(properties[:correlation_id])
        if request
          request.response = payload
          request.set_processed!
          that.client_lock.synchronize { request.condition.signal }
        end
      end
    end

    # hack seankers publisher to get channel and exchange
    def fetch_channel_and_exchange
      ret = nil

      @publisher.instance_eval do
        # ensure_connection connection first
        @mutex.synchronize do
          ensure_connection! unless connected?
        end
        ret = [@channel, @exchange]
      end

      ret
    end
  end
end
