module SneakersPacker
  module RpcWorker
    def self.included(klass)
      klass.class_eval do
        include ::Sneakers::Worker
      end
    end

    def packer
      SneakersPacker.message_packer
    end

    def work_with_params(message, delivery_info, metadata)
      #puts "get #{message}"
      request_data, from = packer.unpack_request message
      #puts "call from #{from}"

      #begin
      response_data = call request_data
      result = packer.pack_response response_data, 200
      # rescue Exception => ex
      #   # caught exeption
      #   result = packer.pack_response nil, 500
      # ensure
      publish(result, to_queue: metadata.reply_to, correlation_id: metadata.correlation_id)

      ack!
      #end
    end

  end
end
