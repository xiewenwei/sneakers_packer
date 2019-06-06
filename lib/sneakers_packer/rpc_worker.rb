module SneakersPacker
  module RpcWorker
    def self.included(klass)
      klass.class_eval do
        include ::Sneakers::Worker
        include BaseWorker
      end
    end

    def work_with_params(message, delivery_info, metadata)
      with_verify_active_record do
        request_data, from = packer.unpack_request message
        response_data = call request_data

        result = packer.pack_response response_data, 200
        publish(result, to_queue: metadata.reply_to, correlation_id: metadata.correlation_id)
        ack!
      end
    end
  end
end
