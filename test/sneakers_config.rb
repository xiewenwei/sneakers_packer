
require 'sneakers'

opts = {
  vhost: '/',
  amqp: 'amqp://127.0.0.1:5672',
  exchange: 'sneakers',
  exchange_type: :direct,
  workers: 1,
  daemonize: false,
  pid: "tmp/pids/sneakers.pid",
  daemon_process_name: "sneakers master [sneaker-test]",
  worker_process_name: "sneakers worker %d [sneaker-test]"
}

Sneakers.configure(opts)

Sneakers.logger.level = Logger::INFO

SneakersPacker.configure do |conf|
  conf.rpc_timeout = 2
  conf.app_name = "sneakers_test"
end
