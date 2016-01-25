module SneakersPacker
  class RpcClient

    attr_reader :reply_queue
    attr_accessor :response, :call_id
    attr_reader :lock, :condition

    def initialize(publisher)
      @publisher = publisher
      channel, exchange = fetch_channel_and_exchange
      @consumer = build_reply_queue(channel, exchange)
    end

    NO_RESPONSE = :__no_resp

    # call remote service via rabbitmq rpc
    # @param name route_key for service
    # @param message
    # @param options{timeout} [int] timeout. seconds.   optional
    # @return result of service
    # @raise RemoteCallTimeoutError if timeout
    def call(name, message, options = {})
      self.call_id = SecureRandom.uuid
      self.response = NO_RESPONSE

      ensure_reply_queue!

      @exchange.publish(message.to_s,
                        routing_key:    name.to_s,
                        correlation_id: call_id,
                        reply_to:       @reply_queue.name)

      timeout = (options[:timeout] || SneakersPacker.conf.rpc_timeout).to_i

      lock.synchronize { condition.wait(lock, timeout) }

      if response == NO_RESPONSE
        raise RemoteCallTimeoutError, "remote call timeout. exceed #{timeout} seconds."
      else
        response
      end
    end

    private

    def ensure_reply_queue!
      reconnected = false
      channel = nil
      exchange = nil

      @publisher.instance_eval do
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

      # rebuid reply_queue when reconnecting occur
      if reconnected
        @consumer = build_reply_queue(channel, exchange)
      end
    end

    def build_reply_queue(channel, exchange)
      @channel, @exchange = channel, exchange

      @reply_queue    = channel.queue("", exclusive: true)
      @reply_queue.bind(exchange, routing_key: @reply_queue.name)

      @lock      = Mutex.new
      @condition = ConditionVariable.new
      that       = self

      @reply_queue.subscribe(manual_ack: false) do |delivery_info, properties, payload|
        if properties[:correlation_id] == that.call_id
          that.response = payload
          that.lock.synchronize { that.condition.signal }
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
