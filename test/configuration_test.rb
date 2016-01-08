require 'test_helper'

describe SneakersPacker::Configuration do
  it "should be instantiated" do
    conf = SneakersPacker::Configuration.new
    assert_equal 5, conf.rpc_timeout
    assert_equal "unknown", conf.app_name
  end

  it "should be configured" do
    # config in test_helper
    assert_equal 8, SneakersPacker.conf.rpc_timeout
    assert_equal "sneakers_test", SneakersPacker.conf.app_name

    # reconfigure
    SneakersPacker.configure do |conf|
      conf.rpc_timeout = 6
      conf.app_name = "sneakers_test2"
    end

    assert_equal 6, SneakersPacker.conf.rpc_timeout
    assert_equal "sneakers_test2", SneakersPacker.conf.app_name
  end

end
