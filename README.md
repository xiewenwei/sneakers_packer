# SneakersPacker [![Build Status][travis-image]][travis-link]

[travis-image]: https://travis-ci.org/xiewenwei/sneakers_packer.svg?branch=master
[travis-link]: http://travis-ci.org/xiewenwei/sneakers_packer
[travis-home]: http://travis-ci.org/

SneakersPacker is a gem for using sneakers to realize 3 message communication patterns job message, broadcast and RPC(remote procedure call).

## Installation

Intall the `sneakers' gem first. see [sneakers](https://github.com/jondot/sneakers)

Then add this line to your application's Gemfile:

```ruby
gem 'sneakers_packer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sneakers_packer

## Usage

### Configuation

SneakersPacker uses most of sneakers configuration for simpleness.
There are `app_name` and `rpc_timeout` should be set for SneakersPacker.

Append below to `config/initializers/sneakers.rb`.

```ruby
SneakersPacker.configure do |conf|
  conf.rpc_timeout = 3             # rpc client timeout. default is 5 seconds.
  conf.app_name = "sneakers_test"  # rpc client or server app's name. default is 'unknown'
end
```

### API usage examples

- Job Message

**Client**

`SneakersPacker.publish("demo", "hello world")`

**Server**

```ruby
  class DemoWorker
    include SneakersPacker::CommonWorker
    from_queue :demo

    def call(data)
      puts "data is #{data}"
      # do something...
    end
  end
```

- Broadcast

**Client**

It is same with Job Message

`SneakersPacker.publish("demo.suprise", "hello world")`

**Server**

It is almost same with Job Message except that one routing_key with multiple queues.

```ruby
  class OneWorker
    include SneakersPacker::CommonWorker

    from_queue :one_name, routing_key: "demo.suprise"

    def call(data)
      puts "one: #{data}"
      # do something...
    end
  end
```

```ruby
  class OtherWorker
    include SneakersPacker::CommonWorker

    from_queue :other_name, routing_key: "demo.suprise"

    def call(data)
      puts "other: #{data}"
    end
  end
```

- RPC

**Client**

remote call with default timeouit. default is 5 seconds.
`SneakersPacker.remote_call("rpc_server", 10)`

remote call with custom timeouit.
`SneakersPacker.remote_call("rpc_server", 12, timeout: 2)`

**Server**

```ruby
  class RpcServerWorker
    include SneakersPacker::RpcWorker

    from_queue :rpc_server

    # return value of call will be result of remote procedure call
    def call(data)
      data.to_i ** 3
    end
  end
```

**See the gem doc or source code for accurate detail**
**You can see the demo app for SneakersPacker by** [Sneakers](https://github.com/xiewenwei/sneakers_demo).

## Development

**How to run test?**

1.start RabbitMQ Server. for mac
`rabbitmq-server`

2.start test workers
`ruby test/sneakers_test_workers.rb`

3.run test
`bundle exec rake test`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xiewenwei/sneakers_packer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

