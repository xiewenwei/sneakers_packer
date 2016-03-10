module SneakersPacker
  class RpcClient

    attr_reader :reply_queue
    attr_accessor :response, :call_id
    attr_reader :lock, :condition

    def initialize(publisher)
      @publisher = publisher
      @queue_name = "rpc.#{SecureRandom.uuid}"

      initialize_bunny
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

      @exchange.publish(message.to_s,
                        routing_key:    name.to_s,
                        correlation_id: call_id,
                        reply_to:       @reply_queue.name)

      timeout = (options[:timeout] || SneakersPacker.conf.rpc_timeout).to_i

      lock.synchronize { condition.wait(lock, timeout) }

      if response == NO_RESPONSE
        raise RemoteCallTimeoutError, "Remote call timeouts.Exceed #{timeout} seconds."
      else
        response
      end
    end

    private

    def initialize_bunny
      pub = SneakersPacker.publisher
      pub_mutext = pub.instance_variable_get :@mutex

      pub_mutext.synchronize do
        pub.send(:ensure_connection!) unless pub.send(:connected?)
      end

      @pub_opt = pub.instance_variable_get :@opt
      @bunny = pub.instance_variable_get :@bunny
      @channel = pub.instance_variable_get :@channel
      @exchange = pub.instance_variable_get :@exchange
      @consumer = build_reply_queue
    end

    def build_reply_queue
      @reply_queue    = @channel.queue(@queue_name, exclusive: true)
      @reply_queue.bind(@exchange, routing_key: @reply_queue.name)

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
  end
end
