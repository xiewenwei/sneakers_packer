module SneakersPacker
  module CommonWorker
    def self.included(klass)
      klass.class_eval do
        include ::Sneakers::Worker
      end
    end

    def packer
      SneakersPacker.message_packer
    end

    def work(message)
      #puts "get #{message}"
      request_data, from = packer.unpack_request message
      #puts "call from #{from}"
      call request_data
      ack!
    end
  end
end
