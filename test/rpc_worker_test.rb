require 'test_helper'

module SneakersPacker
  class DemoRpcWorker
    attr_reader :value
    include RpcWorker
    from_queue :demo_rpc

    def call(data)
      @value = data.to_i + 1
    end
  end
end

describe SneakersPacker::RpcWorker do
  it "should be defined" do
    worker = SneakersPacker::DemoRpcWorker.new
    worker.call 10
    assert worker.kind_of?(SneakersPacker::RpcWorker)
    assert worker.kind_of?(Sneakers::Worker)
  end

  it "should work" do
    worker = SneakersPacker::DemoRpcWorker.new
    worker.stubs(:ack!).returns(true)
    worker.stubs(:publish).returns(true)

    metadata = mock(reply_to: 1, correlation_id: 2)

    worker.work_with_params '{"data": 5}', nil, metadata
    assert_equal 6, worker.value
  end
end