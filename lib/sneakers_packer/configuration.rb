module SneakersPacker
  class Configuration
    attr_accessor :app_name, :rpc_timeout

    # default timeout for remote call. unit is seconds
    DEFAULT_RPC_TIMEOUT = 5

    def initialize
      @app_name = 'unknown'
      @rpc_timeout = DEFAULT_RPC_TIMEOUT
    end
  end

  def self.conf
    @conf ||= Configuration.new
  end

  def self.configure(&block)
    block.call self.conf
  end
end
