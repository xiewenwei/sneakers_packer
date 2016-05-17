
require 'sneakers'

opts = {
  vhost: '/',
  exchange: 'sneakers',
  exchange_type: :direct,
  workers: 2,
  daemonize: false,
  pid: "tmp/pid/sneakers.pid"
}

Sneakers.configure(opts)

Sneakers.logger.level = Logger::INFO

SneakersPacker.configure do |conf|
  conf.rpc_timeout = 1
  conf.app_name = "sneakers_test"
end
