require 'test_helper'

class SneakersPackerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SneakersPacker::VERSION
  end

  def test_publisher
    refute_nil SneakersPacker.publisher
  end

  def test_message_packer
    refute_nil SneakersPacker.message_packer
  end

  def test_remote_call_timeout_error
    raise SneakersPacker::RemoteCallTimeoutError, "timeout"
  rescue => e
    assert e.is_a?(SneakersPacker::RemoteCallTimeoutError)
  end

  def test_publish
    SneakersPacker.publish "sneakers_packer_test.demo1", "ok"
  end

  def test_remote_call1
    result = SneakersPacker.remote_call "sneakers_packer_test.rpc1", 101
    assert_equal 102, result
  end

  def test_remote_call2
    result = SneakersPacker.remote_call "sneakers_packer_test.rpc2", 101
    assert_equal 101 ** 2, result
  end

  def test_multi_threads
    result = {}
    mutex = Mutex.new

    25.times.map do |index|
      Thread.new {
        mutex.synchronize {
          result[index] = SneakersPacker.remote_call "sneakers_packer_test.rpc1", index
        }
      }
    end.each(&:join)

    assert_equal 25, result.size

    result.each do |k, v|
      assert_equal v, k + 1
    end
  end

  def test_multi_threads_with_rand_delay
    result = {}
    mutex = Mutex.new

    25.times.map do |index|
      Thread.new {
        mutex.synchronize {
          result[index] = SneakersPacker.remote_call "sneakers_packer_test.rpc2", index
        }
      }
    end.each(&:join)

    assert_equal 25, result.size

    result.each do |k, v|
      assert_equal v, k * k
    end
  end
end
