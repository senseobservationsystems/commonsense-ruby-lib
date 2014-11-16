source 'https://rubygems.org'

# Specify your gem's dependencies in cs.gemspec
gemspec
gem "time-lord"
gem 'json'

#
# Rubinius does not load ruby stdlib by default
#

platforms :rbx do
#  gem 'rubysl'
end

group :test do
  gem "rake", "~> 10.1.0"
  gem "webmock", "~> 1.13.0"
  gem "rspec", "~> 2.14.1"
  gem "codeclimate-test-reporter", require: nil
end

group :development do
  gem "pry"
  gem "pry-nav"
  gem "pry-doc"
end
