module SneakersPacker
  module CommonWorker
    def self.included(klass)
      klass.class_eval do
        include ::Sneakers::Worker
        include BaseWorker
      end
    end

    def work(message)
      with_verify_active_record do
        request_data, from = packer.unpack_request message
        call request_data
        ack!
      end
    end
  end
end
