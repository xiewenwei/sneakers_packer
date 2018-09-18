require 'securerandom'

module SneakersPacker
  class RpcReplySubscriber

    def initialize(client, publisher)
      @client = client
      @publisher = publisher
      @queue_name = "rpc.#{SecureRandom.uuid}"

      initialize_reply_queue
    end

    def reply_queue_name
      @queue_name
    end

    private

    def initialize_reply_queue
      # ensure_connection
      @publisher.ensure_connection!

      channel = @publisher.instance_variable_get :@channel
      exchange = @publisher.instance_variable_get :@exchange
      build_reply_queue(channel, exchange)
    end

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
          Sneakers.logger.warn "#{properties[:correlation_id]}'s request is not found"
        end
      end
    end
  end
end
