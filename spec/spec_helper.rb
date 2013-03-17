require 'bundler/setup'
require 'rspec'
require 'commonsense-ruby-lib'
#require 'vcr'
require 'pry'

Dir[File.join(File.dirname(__FILE__),("support/**/*.rb"))].each {|f| require f}

CONFIG = YAML.load(File.read(File.expand_path("support/spec_config.yml", File.dirname(__FILE__))))

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # create a single user
  config.before(:all) do

      unless $user
        $username = "user#{Time.now.to_f}@tester.com"
        $password = "password"

        client = CommonSense::Client.new(base_uri: ENV['spec_base_uri'])
        $user = client.new_user
        $user.username = $username
        $user.email = $user.username
        $user.password = 'password'
        $user.name = 'Jan'
        $user.surname = 'jagger'
        $user.address = 'Lloydstraat 5'
        $user.zipcode = '3024ea'
        $user.country = 'NETHERLANDS'
        $user.mobile = '123456789'
        $user.save
      end
  end
end

def create_client
  CommonSense::Client.new(base_uri: ENV['spec_base_uri'])
end

ENV['spec_base_uri'] ||= 'http://localhost:8080'
