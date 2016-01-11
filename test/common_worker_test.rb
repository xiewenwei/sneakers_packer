require 'test_helper'

module SneakersPacker
  class DemoWorker
    attr_reader :value
    include CommonWorker
    from_queue :demo

    def call(data)
      @value = data
    end
  end
end

describe SneakersPacker::CommonWorker do
  it "should be defined" do
    worker = SneakersPacker::DemoWorker.new
    worker.call "hello"
    assert worker.kind_of?(SneakersPacker::CommonWorker)
    assert worker.kind_of?(Sneakers::Worker)
  end

  it "should work" do
    worker = SneakersPacker::DemoWorker.new
    worker.stub(:ack!, nil) {}
    worker.work '{"data": "good news"}'
    assert_equal "good news", worker.value
  end
end
