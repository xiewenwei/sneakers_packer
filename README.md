# SneakersPacker

SneakersPacker is a gem for using sneakers to 3 message communication patterns job message, broadcast and RPC(remote procedure call).

## Installation

Add this line to your application's Gemfile:

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
Only one exception is that it use app_name for identitying the source of client.


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
      puts "data is #{message}"
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

```
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

`SneakersPacker.remote_call("rpc_server", 10)`

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sneakers_packer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

