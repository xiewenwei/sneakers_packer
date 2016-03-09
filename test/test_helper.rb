$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../', __FILE__)
require 'sneakers_packer'
require 'sneakers_config'

require 'minitest/autorun'
require 'mocha/mini_test'
