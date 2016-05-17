lib_path = File.expand_path('../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift lib_path

require 'sneakers'
require 'sneakers/runner'
require 'sneakers_packer'
require "#{lib_path}/../test/sneakers_config.rb"

class TestCommonWorker
  include SneakersPacker::CommonWorker

  from_queue "sneakers_packer_test.demo1"

  def call(data)
    logger.info "receive #{data}"
  end
end

class TestRpc1Worker
  include SneakersPacker::RpcWorker
  from_queue "sneakers_packer_test.rpc1"

  def call(data)
    logger.info "rpc1 receive #{data}"
    data.to_i + 1
  end
end

class TestRpc2Worker
  include SneakersPacker::RpcWorker
  from_queue "sneakers_packer_test.rpc2"

  def call(data)
    logger.info "rpc2 receive #{data}"
    sleep rand
    data.to_i ** 2
  end
end

runner = Sneakers::Runner.new([TestCommonWorker, TestRpc1Worker, TestRpc2Worker])
runner.run
