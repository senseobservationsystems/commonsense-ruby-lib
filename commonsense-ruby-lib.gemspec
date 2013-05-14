# -*- encoding: utf-8 -*-
require File.expand_path('../lib/commonsense-ruby-lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ahmy Yulrizka"]
  gem.email         = ["ahmy@sense-os.nl"]
  gem.description   = %q{CommonSense API client library}
  gem.summary       = %q{Client library to communicate with CommonSense written in ruby}
  gem.homepage      = "https://github.com/senseobservationsystems/commonsense-ruby-lib"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cs"
  gem.require_paths = ["lib"]
  gem.version       = CommonSense::VERSION
  gem.add_development_dependency("rspec", "~> 2.13.0")
  gem.add_development_dependency("launchy", "~> 2.3.0")
  gem.add_development_dependency("fakeweb", "~> 1.3.0")
  gem.add_dependency('httparty', '~> 0.11.0')
  gem.add_dependency('oauth', '~> 0.4.7')
end
