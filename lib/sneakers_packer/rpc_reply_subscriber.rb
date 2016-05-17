module SneakersPacker
  class RpcReplySubscriber

    def initialize(client, publisher)
      @client = client
      @publisher = publisher
      @queue_name = "rpc.#{SecureRandom.uuid}"

      @build_reply_queue_lock = Mutex.new

      @build_reply_queue_lock.synchronize {
        build_reply_queue(*fetch_channel_and_exchange)
      }
    end

    def reply_queue_name
      @queue_name
    end

    def ensure_reply_queue!
      reconnected = false
      channel = nil
      exchange = nil

      # Hacking code for geting channel and exchange
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
        @build_reply_queue_lock.synchronize {
          build_reply_queue(channel, exchange)
        }
      end
    end

    private

    def build_reply_queue(channel, exchange)
      @reply_queue = channel.queue(@queue_name, exclusive: true)

      @reply_queue.bind(exchange, routing_key: @reply_queue.name)

      that = @client

      @reply_queue.subscribe(manual_ack: false) do |delivery_info, properties, payload|
        request = that.request_hash[properties[:correlation_id]]
        if request
          request.response = payload
          request.set_processed!
          that.client_lock.synchronize { request.condition.signal }
        else
          puts "#{properties[:correlation_id]}'s request is not found"
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
        # The @channel and @exchange are instance of @publisher, not self
        ret = [@channel, @exchange]
      end

      ret
    end
  end
end
