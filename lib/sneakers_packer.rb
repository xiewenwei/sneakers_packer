require "sneakers"
require "sneakers_packer/version"
require "sneakers_packer/configuration"
require "sneakers_packer/message_packer"
require "sneakers_packer/common_worker"
require "sneakers_packer/rpc_worker"
require "sneakers_packer/rpc_client"

module SneakersPacker
  class RemoteCallTimeoutError < Exception; end

  # sender message to sneaker exchange
  # @param name route_key for message
  # @param data
  def self.publish(name, data)
    message = message_packer.pack_request(data)

    publisher.publish message, to_queue: name
  end

  # call remote service via rabbitmq rpc
  # @param name route_key for service
  # @param data
  # @param options{timeout} [int] timeout. seconds.   optional
  # @return result of service
  # @raise RemoteCallTimeoutError if timeout
  #
  def self.remote_call(name, data, options = {})
    @client ||= RpcClient.new(publisher)
    message = packer.pack_request(data)
    response = @client.call name, message, options
    response_data, from, status = message_packer.unpack_response(response)
    response_data
  end

  def self.publisher
    @publisher ||= ::Sneakers::Publisher.new
  end

  # message_packer is a singleton object
  def self.message_packer
    @message_packer ||= MessagePacker.new(self.conf.app_name)
  end
end
