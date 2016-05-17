module SneakersPacker
  class RpcClient
    attr_reader :client_lock, :request_hash

    def initialize(publisher)
      @publisher = publisher
      @client_lock = Mutex.new
      @request_lock = Mutex.new
      @request_hash = {}

      @subscriber = RpcReplySubscriber.new self, publisher
    end

    # call remote service via rabbitmq rpc
    # @param name route_key for service
    # @param message
    # @param options{timeout} [int] timeout. seconds.   optional
    # @return result of service
    # @raise RemoteCallTimeoutError if timeout
    def call(request, options = {})
      @subscriber.ensure_reply_queue!

      add_request(request)

      @publisher.publish(request.message,
                         routing_key: request.name,
                         correlation_id: request.call_id,
                         reply_to: @subscriber.reply_queue_name)

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
  end
end
