require 'securerandom'

module SneakersPacker
  class RpcRequest
    attr_reader :name, :call_id, :condition
    attr_reader :response_data, :from, :status

    def initialize(name, data)
      @name = name.to_s
      @data = data
      @call_id = SecureRandom.uuid

      @response = nil
      @processed = false
      @condition = ConditionVariable.new
    end

    def message
      SneakersPacker.message_packer.pack_request(@data)
    end

    def processed?
      @processed
    end

    def set_processed!
      @processed = true
    end

    def response=(value)
      @response_data, @from, @status = nil, nil, nil
      @response = value
      if value
        @response_data, @from, @status = SneakersPacker.message_packer.unpack_response(value)
      end
    end
  end
end
