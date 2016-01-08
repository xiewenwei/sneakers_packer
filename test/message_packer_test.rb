require 'test_helper'

describe SneakersPacker::MessagePacker do
  before do
    @packer = ::SneakersPacker::MessagePacker.new "sneaker_demo_test"
  end

  it "pack request" do
    message = @packer.pack_request 1
    assert_match /\"from\":\"sneaker_demo_test/, message
    assert_match /\"data\":1/, message
  end

  it "unpack request" do
    message = "{\"from\" : \"one boohee-tiger 6354\", \"data\" : 12 }"
    data, from = @packer.unpack_request message
    assert_equal 12, data
    assert_equal "one boohee-tiger 6354", from
  end

  it "pack response" do
    message = @packer.pack_response "ok", 200
    assert_match /\"from\":\"sneaker_demo_test/, message
    assert_match /\"data\":\"ok\"/, message
    assert_match /\"status\":200/, message
  end

  it "unpack response" do
    message = "{\"from\" : \"one boohee-tiger 6355\", \"status\" : 200, \"data\" : \"success\" }"
    data, from, status = @packer.unpack_response message
    assert_equal "success", data
    assert_equal "one boohee-tiger 6355", from
    assert_equal 200, status
  end

  it "pack request with nil data" do
    message = @packer.pack_request nil
    assert_match /\"from\":\"sneaker_demo_test/, message
    assert_match /\"data\":null/, message
  end

  it "create message_packer" do
    refute_nil SneakersPacker.message_packer
  end
end