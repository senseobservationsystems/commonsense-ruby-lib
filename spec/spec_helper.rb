require 'bundler/setup'
require 'rspec'
require 'commonsense-ruby-lib'
#require 'vcr'
require 'pry'

Dir[File.join(File.dirname(__FILE__),("support/**/*.rb"))].each {|f| require f}

CONFIG = YAML.load(File.read(File.expand_path("support/spec_config.yml", File.dirname(__FILE__))))

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

