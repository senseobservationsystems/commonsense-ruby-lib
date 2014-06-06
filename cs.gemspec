# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ahmy Yulrizka"]
  gem.email         = ["ahmy@sense-os.nl"]
  gem.description   = %q{CommonSense API client library}
  gem.summary       = %q{Client library to communicate with CommonSense written in ruby}
  gem.homepage      = "https://github.com/senseobservationsystems/commonsense-ruby-lib"

  gem.required_ruby_version = '>= 1.9.3'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cs"
  gem.require_paths = ["lib"]
  gem.version       = CS::VERSION
  gem.add_development_dependency("launchy", "~> 2.3")
  gem.add_development_dependency("pry", "~> 0.9.12.6")
  gem.add_dependency('httparty', '~> 0.12')
  gem.add_dependency('oauth', '~> 0.4')
end
