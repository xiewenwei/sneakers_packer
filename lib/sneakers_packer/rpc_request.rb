module SneakersPacker
  class RpcRequest
    attr_reader :name, :message, :call_id, :condition
    attr_accessor :response

    def initialize(name, message)
      @name = name.to_s
      @message = message.to_s
      @call_id = SecureRandom.uuid

      @response = nil
      @processed = false
      @condition = ConditionVariable.new
    end

    def processed?
      @processed
    end

    def set_processed!
      @processed = true
    end
  end
end
