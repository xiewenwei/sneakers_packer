$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sneakers_packer'
require 'sneakers_config'

require 'minitest/autorun'
require 'mocha/mini_test'

# Local RabbitMQ server and workers must be started before testing.
# start rammitmq
# rabbitmq-server
# start workers
# ruby test/sneakers_test_workers.rb
