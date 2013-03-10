require 'spec_helper'

describe "User management" do

  describe "Manage user" do

    let!(:user) do
      unless $user
        client = CommonSense::Client.new(base_uri: ENV['spec_base_uri'])
        $user = client.new_user
        $user.username = "user#{Time.now.to_f}@tester.com"
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

      $user
    end

    it "create new user" do
      current_user = user
      current_user.id.should_not be_nil
    end

    it "get user data from commonSense" do
      attributes = user.to_h

      client = CommonSense::Client.new(base_uri: ENV['spec_base_uri'])
      client.login(user.username, 'password')
      
      current_user = client.current_user

      attributes.each do |key, value|
        next if key == :password
        current_user.send(key).should eq(value)
      end
    end

    it "update user" do
      current_time = Time.now.to_f
      expected = { username: "user-edit-#{current_time}@tester.com",
        email: "user-edit-#{current_time}@tester.com",
        name: "Jan Edit",
        surname: "jagger edit",
        address: 'Looydstraat 5 edit',
        zipcode: '12345',
        country: 'GERMANY',
        mobile: '987654321'
      }

      client = CommonSense::Client.new(base_uri: ENV['spec_base_uri'])
      client.login(user.username, 'password')

      current_user = client.current_user

      expected.each do |key, value|
        current_user.send("#{key}=".to_sym, value) 
      end

      current_user.save
      current_user.reload

      expected.each do |key,value|
        current_user.send(key).should eq(value)
      end

    end
  end
end
