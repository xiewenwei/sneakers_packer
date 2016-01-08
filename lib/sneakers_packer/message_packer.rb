require 'socket'
require 'multi_json'

module SneakersPacker
  class MessagePacker
    attr_reader :from_info

    def initialize(app_name = nil)
      app_name ||= 'unknown'
      @from_info = "#{app_name} #{Socket.gethostname} #{Process.pid}"
    end

    # Pack request data with standart json format
    # It should include from_info and data
    #  @param data payload for request
    #  @return [string] json string body
    #  @example
    #    param data = 12
    #    return {"from" : "one boohee-tiger 6354", "data" : 12 }
    #  @example
    #    param data = ["ok", name: "vincent"]
    #    return "{\"from\" : \"one boohee-tiger 6354\", \"data\" : [\"1\", {\"name\" : \"vincent\"}]}"

    def pack_request(data)
      MultiJson.dump "data" => data, "from" => @from_info
    end

    # Unpack request data which is standart json format
    # It should include status, message(optional) and data
    # @param body response raw data
    # @return hash
    # @example
    #   param message = "{\"from\":\"boohee\", \"data\":12}"
    #   return array [12, "boohee"]

    def unpack_request(message)
      hash = unpack_message(message)
      [hash["data"], hash["from"]]
    end

    def pack_response(data, status)
      MultiJson.dump "data" => data, "from" => @from_info, "status" => status
    end

    # Unpack response data which is standart json format
    # It should include status, message(optional) and data
    # @param body response raw data
    # @return hash
    # @example
    #   param message = "{\"status\":200, \"data\":2}"
    #   return array [2, 200]

    def unpack_response(message)
      hash = unpack_message(message)
      [hash["data"], hash["from"], hash["status"]]
    end

    private

    def pack_data(data)
      MultiJson.dump data
    end

    def unpack_message(message)
      MultiJson.load message
    end
  end

  # message_packer is a singleton object
  def self.message_packer
    @message_packer ||= MessagePacker.new(self.conf.app_name)
  end
end
