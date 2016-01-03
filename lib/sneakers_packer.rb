require 'sneakers'
require "sneakers_packer/version"

module SneakersPacker
  class RemoteCallTimeoutError < Exception; end

  autoload :MessagePacker, "sneakers_packer/message_packer"
  autoload :CommonWorker, "sneakers_packer/common_worker"
  autoload :RpcWorker, "sneakers_packer/rpc_worker"
  autoload :RpcClient, "sneakers_packer/rpc_client"

  # sender message to sneaker exchange
  # @param name route_key for message
  # @param data
  def self.publish(name, data)
    message = packer.pack_request(data)
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
    response_data, from, status = packer.unpack_response(response)
    response_data
  end

  def self.publisher
    @publisher ||= ::Sneakers::Publisher.new
  end

  def self.packer
    @packer ||= MessagePacker.new("sneaker_demo")
  end
end
