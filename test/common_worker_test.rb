require 'test_helper'

module SneakersPacker
  class DemoWorker
    include CommonWorker
    from_queue :demo

    def call(data)
      #puts "data is #{data}"
      # do nothing
    end
  end
end

describe SneakersPacker::CommonWorker do
  it "should be defined" do
    worker = SneakersPacker::DemoWorker.new
    worker.call "hello"
    assert worker.kind_of?(SneakersPacker::CommonWorker)
  end

  it "should work" do

  end
end
