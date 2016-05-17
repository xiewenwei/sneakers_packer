require 'test_helper'

describe SneakersPacker::RpcClient do
  it "should create rpc client instance and be called" do
    rpc_client = SneakersPacker::RpcClient.new SneakersPacker.publisher
    assert_equal Hash.new, rpc_client.request_hash
    refute_nil rpc_client.client_lock

    message = SneakersPacker.message_packer.pack_request("")
    request = SneakersPacker::RpcRequest.new "unknown.rpc", message

    assert_raises SneakersPacker::RemoteCallTimeoutError do
      rpc_client.call request
    end
  end

end
