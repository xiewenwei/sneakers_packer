require 'securerandom'
require "sneakers"
require "sneakers_packer/version"
require "sneakers_packer/configuration"
require "sneakers_packer/message_packer"
require "sneakers_packer/base_worker"
require "sneakers_packer/common_worker"

require "sneakers_packer/rpc_worker"
require "sneakers_packer/rpc_request"
require "sneakers_packer/rpc_reply_subscriber"
require "sneakers_packer/rpc_client"

module SneakersPacker
  class RemoteCallTimeoutError < StandardError; end

  # sneakers_packer_mutex is mutex for class instance variables initialization
  @sneakers_packer_mutex = Mutex.new
  @publish_mutex = Mutex.new

  class << self
    # sender message to sneaker exchange
    # @param name route_key for message
    # @param data
    def publish(name, data)
      message = message_packer.pack_request(data)
      @publish_mutex.synchronize do
        publisher.publish message, to_queue: name
      end
    end

    # call remote service via rabbitmq rpc
    # @param name route_key for service
    # @param data
    # @param options{timeout} [int] timeout. seconds.   optional
    # @return result of service
    # @raise RemoteCallTimeoutError if timeout
    #
    def remote_call(name, data, options = {})
      request = RpcRequest.new name, data

      rpc_client.call request, options
    end

    # publisher is a singleton object
    def publisher
      if !@publisher
        @sneakers_packer_mutex.synchronize {
          @publisher ||= ::Sneakers::Publisher.new
        }
      end
      @publisher
    end

    # message_packer is a singleton object
    def message_packer
      if !@message_packer
        @sneakers_packer_mutex.synchronize {
          @message_packer ||= MessagePacker.new(self.conf.app_name)
        }
      end
      @message_packer
    end

    def rpc_client
      if !@rpc_client
        _publisher = publisher
        @sneakers_packer_mutex.synchronize {
          @rpc_client ||= RpcClient.new(_publisher)
        }
      end
      @rpc_client
    end
  end
end
