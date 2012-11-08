require 'commonsense-ruby-lib'
client = CommonSense::Client.new
client.setSessionID('1935509b9c49eedc26.41736537')
puts client.current_user.to_h
