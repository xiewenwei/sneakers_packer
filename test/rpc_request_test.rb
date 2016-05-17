require 'test_helper'

describe SneakersPacker::RpcRequest do
  it "should create request" do
    request = SneakersPacker::RpcRequest.new "test.request", 100
    assert_equal "test.request", request.name
    assert_equal "100", request.message
    refute_nil request.condition
    refute_nil request.call_id
    assert_nil request.response
    assert !request.processed?
  end

  it "should set to processed" do
    request = SneakersPacker::RpcRequest.new "test.request", nil
    assert_equal "", request.message
    assert !request.processed?
    request.set_processed!
    assert request.processed?
  end
end
