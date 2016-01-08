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
end
