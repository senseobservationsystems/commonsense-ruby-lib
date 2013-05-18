# Commonsense::Ruby::Lib
Client library to communicate with CommonSense written in ruby

## Installation

Add this line to your application's Gemfile:

    gem 'cs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cs

## Usage

### Authentication
```ruby
client = CS::Client.new
client.login('username','password')

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

## Testing

    $ cp spec/support/spec_config.yml.sample spec/support/spec_config.yml
    $ rspec

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
