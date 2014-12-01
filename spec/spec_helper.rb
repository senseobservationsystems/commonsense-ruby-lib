#ENV['CODECLIMATE_REPO_TOKEN'] = "a4b19928b743eda49f7acaba02190126122bfa09bb2615395aa1820a7cce9fc0"
# code climate
if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'bundler/setup'
require 'rspec'
require 'cs'
require 'pry'


Dir[File.join(File.dirname(__FILE__),("support/**/*.rb"))].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.after(:suite) do
      WebMock.disable_net_connect!(:allow => 'codeclimate.com')
  end
end

def create_client
  CS::Client.new(base_uri: ENV['spec_base_uri'])
end

ENV['spec_base_uri'] ||= 'http://api.dev.sense-os.local'

def base_uri
  ENV['spec_base_uri']
end
