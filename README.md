# Ractor::Supervisor

Experimental port of Elixir's `Supervisisor` functionality for Ruby `Ractor`s.

*Note*: I lack experience with actors and I'm quite unsure of where this is going.

## Installation

```ruby
gem 'ractor-supervisor'
```

## Usage


```ruby
class Example < Ractor::Server
  def initialize(initial = nil)
    puts "Starting #{initial}"
  end

  def run
    loop do
      value = Ractor.receive
      puts "Processing #{value}"
    end
  end
end

boss = Ractor::Supervisor.new(
  Example,
  [Example, 'initial arg'],
  strategy: :one_for_one
)

specs = Ractor::Supervisor::Specs.new(strategy: :one_for_one) do |spec|
  spec.add Example,
  spec.add Example, args: 'initial arg', name: 'ex2'
  spec.add args: 'initial arg', name: 'ex2', restart: :permanent do |*args|
    Example.new(*args).run
  end
end

boss = Ractor::Supervisor.new(specs)

# prints => "Starting "
# prints => "Starting initial arg"
supervised = boss.children.last
supervised << 'bar'
# prints "Processing bar"

class Buggy
  def to_s
    raise 'oops'
  end
end
supervised << Buggy.new
# kills ractor, Supervisor recreates it
# prints => "Starting initial arg"
supervised << 'baz'
# prints "Processing baz"

Ractor.shareable?(boss) # => true
```

## Implementation details

### Server

Server is a protocol to declare a class with behavior on the client side and on the server side. It actually defines two classes, the Server itself, and the Client.

The client holds (only) the ractor of the server. Its methods are the methods of the server, with the implementation is to yield the method name and any arguments to the servers. For `sync` methods, the current ractor is also sent and the result is `receive`d before returning.

Methods expecting a block can also run their block either server-side, or client-side [todo: default?, todo: naming one or the other?]. Executing them client-side is done with a Thread.


### Supervisor


The `supervise` method returns a `Ractor::Supervised` that delegates most calls to the current Ractor. If it crashes, this Ractor will be changed for a new one. The method `ractor` returns the current Ractor.

The `Supervisor` assumes that `Ractor.yield` is *not* used by the supervised ractors.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcandre/ractor-supervisor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/marcandre/ractor-supervisor/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ractor::Supervisor project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/marcandre/ractor-supervisor/blob/master/CODE_OF_CONDUCT.md).
