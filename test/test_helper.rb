$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sneakers_packer'
require 'sneakers_config'

require 'minitest/autorun'
require 'mocha/mini_test'

# Local RabbitMQ server must be started when run test
