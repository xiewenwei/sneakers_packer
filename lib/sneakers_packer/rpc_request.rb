module SneakersPacker
  class RpcRequest
    attr_reader :name, :message, :call_id
    attr_accessor :response

    def initialize(name, message)
      @name = name.to_s
      @message = message.to_s
      @call_id = SecureRandom.uuid

      @response = nil
      @processed = false
    end

    def processed?
      @processed
    end

    def set_processed!
      @processed = true
    end

    def condition
      @condition ||= ConditionVariable.new
    end
  end
end
