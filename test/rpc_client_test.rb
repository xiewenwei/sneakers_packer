require 'test_helper'

describe SneakersPacker::RpcClient do
  it "should create rpc client instance and be called" do
    rpc_client = SneakersPacker::RpcClient.new SneakersPacker.publisher
    assert_equal Hash.new, rpc_client.request_hash
    refute_nil rpc_client.client_lock

    request = SneakersPacker::RpcRequest.new "sneakers_packer_test.rpc1", 101
    assert_equal 102, rpc_client.call(request)

    assert_equal 102, request.response_data
  end

end
