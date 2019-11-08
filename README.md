[![Build Status](https://travis-ci.org/hshimoyama/active_decorator-graphql.svg?branch=master)](https://travis-ci.org/hshimoyama/active_decorator-graphql)

# ActiveDecorator::GraphQL

A toolkit for decorationg GraphQL field objects using [ActiveDecorator](https://github.com/amatsuda/active_decorator).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_decorator-graphql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_decorator-graphql

## Usage

### Decorate All fields

- Model

```rb
class Author < ActiveRecord::Base
  # first_name:string last_name:string
end
```

- Decorator

```rb
module AuthorDecorator
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

- GraphQL Type

```rb
Types::AuthorType = GraphQL::ObjectType.define do
  name "Author"
  field :full_name, !types.String
end
```

then GraphQL::Field resolves `full_name` by decorated Author objects.

### Decorate only specific fields

If you want to decorate only specific fields ActiveDecorater::GraphQL provides options to control decoration default and field decoration.
Class-based API does not support decorate option.

- Control decoration defaults (config/initializers/active_decorator-graphql.rb)

```rb
ActiveDecorator::GraphQL::Config.decorate = false # default: true
```

- Control specific field decoration (GraphQL Type)

```rb
Types::AuthorType = GraphQL::ObjectType.define do
  name "Author"
  field :full_name, !types.String, decorate: true
  # true:  force enabling decoration
  # false: force disabling decoration
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hshimoyama/active_decorator-graphql.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
