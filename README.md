# Commonsense::Ruby::Lib
Client library to communicate with CommonSense written in ruby

## Installation

Add this line to your application's Gemfile:

    gem 'commonsense-ruby-lib'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install commonsense-ruby-lib

## Usage

```ruby
client = CommonSense::Client.new
client.login('a','a') 

current_user = client.current_user # get current_user
groups = current_user.groups # get groups where users belongs to
```

## Testing

    $ cp spec/support/spec_config.yml.sample spec/support/spec_config.yml
    $ rspec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
