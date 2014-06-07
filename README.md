# Commonsense::Ruby::Lib
Client library to communicate with CommonSense written in ruby

[![Gem Version](https://badge.fury.io/rb/cs.svg)](http://badge.fury.io/rb/cs)
[![Code Climate](https://codeclimate.com/github/senseobservationsystems/commonsense-ruby-lib.png)](https://codeclimate.com/github/senseobservationsystems/commonsense-ruby-lib)
[![Build Status](https://travis-ci.org/senseobservationsystems/commonsense-ruby-lib.png?branch=master)](https://travis-ci.org/senseobservationsystems/commonsense-ruby-lib)

## Installation

Install with rubygems :

    $ gem install cs
    
If you use Bundler to manage gem dependency, add this line to your Gemfile:

    gem 'cs'

And then execute:

    $ bundle

## Usage

### Authentication
```ruby
client = CS::Client.new
client.login('username','password')

# setting session_id manually

client = CS::Client.new
client.session_id = '1234'

# get current user
current_user = client.current_user
```

### Querying Sensor
```ruby
# create sensors relation
sensors = client.sensors

# is the same as
sensors = CS::Relation::Sensors.new
sensors.session = session

# Get all sensor
sensors = client.sensors
sensors.to_a

# show parameters available when querying
client.sensors.parameters

# Get sensor by specifying parameters
client.sensors.where(page: 0, per_page: 1000)
client.sensors.where(owned: true)
client.sensors.where(physical: true)
client.sensors.where(page: 0, per_page: 1000, physical: true, owned: true, details: "full")

# process each sensor
client.sensors.where(owned: true).each {|sensor| puts sensor.name}

# Chain parameters
client.sensors.where(page:0, per_page: 10).where(physical: true)

# Find sensor by name
client.sensors.find_by_name(/position/)
client.sensors.find_by_name(/position/, owned: true) # or
client.sensors.where(owned: true).find_by_name(/position/)

# Get first sensor or last sensor
sensor = client.sensors.first
sensor = client.sensors.last

# Get number of sensors
client.sensors.count
client.sensors.where(owned: true).count
```

### Creating Sensor

```ruby
sensor = client.sensor.build
sensor.name = "light"
sensor.display_name = "Light"
sensor.device_type = "Android"
sensor.pager_type = ""
sensor.data_type = "json"
sensor.data_structure = {lux: "integer"}
sensor.save!
```

### Uploading data point

```ruby
# Find the first position sensor
sensor = client.sensors.find_by_name(/position/).first

# save data point
data = sensor.data.build
data.date = Time.now
data.value = {"lux" => 1}
data.save!

# more compact version
sensor.data.build(date: Time.now, value: {"lux" => 1}).save!
```

### Debuging

To get information about the API response (body, code, headers) inspect the session

example

```ruby
# do some API call
current_user = client.current_user

# get the session
session = client.session

response_code = session.response_code
response_body = session.resopnse_body
header = session.response_headers

# dump the output to text file
session.dump_to_text("/tmp/output.txt")

# open output in browser. Require 'launchy' gem
session.open_in_browser
```

## Command Line Executable

This gem also contain executables to run from command line. The main executable is `cs`

```bash
$ cs -h
Usage: cs <command>

    -h, --help                       Show this message

Available commands are:

    console       Run REPL console based on PRY
    password      Generate hased password from plaintext

```

The console executable will run an REPL (Read Evaluate Print Loop) session based on pry.

install `pry` first in order to use it. `pry-doc` and `pry-nav` is optional

```bash
$ gem install pry
$ gem install pry-doc
$ gem install pry-nav
```

you can have a configuration file on `~/.cs.yml` which contain the following

```yaml
users:
  user1:
    username: "user1@example.com"
    password: ""
    password_md5: 1234567890abcdef1234567890abcdef
  user2:
    username: "user2@example.com"
    password: "V3rryS3curePaswd"
    password_md5: ""

default_user: user1
```

you can either fill in the password or md5-hashed password. It will use `password_md5` if you fill in both


now you can use it on cs console

```bash
$ cs console
CS console 0.1.1

# create a client with default user

[1] pry(main)> client = new_client()
Successfully logged in with user 'user1@example.com'
=> #<CS::Client:0x00000004cd7540
 @base_uri="https://api.sense-os.nl",
 @session=SESSION_ID "1234567890abcdefg1.23456789">

# create a client with another user

[2] pry(main)> user2_client = new_client("user2")
Successfully logged in with user 'user2@example.com'
=> #<CS::Client:0x00000004cd7560
 @base_uri="https://api.sense-os.nl",
 @session=SESSION_ID "1234567890abcdefg1.23456789">

# create an empty client object and will not do the login

[3] pry(main)> empty_client = new_client(false)
> #<CS::Client:0x00000004cf2cf0 @base_uri="https://api.sense-os.nl">
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
