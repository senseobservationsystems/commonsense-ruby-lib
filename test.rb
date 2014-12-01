require 'logger'
require 'pry'
require 'cs'

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
cl1 = CS::Client.new
cl1.logger = logger

puts "loggin cl1"
cl1.login!('ahmy+sf@sense-os.nl', 'sfpassword')
puts "current_user cl1"
cl1.current_user

cl2 = CS::Client.new(base_uri: 'http://api.test.sense-os.nl')
cl2.logger = logger
puts "loggin cl2"
cl2.login('a', 'a')
puts "current_user cl2"
cl2.current_user

cl1.current_user
puts "current_user cl1 again"

binding.pry
