require 'spec_helper'
require 'webmock/rspec'

describe "User management" do

  describe "Manage user" do

    let!(:user) do
      username = "user1@tester.com"
      password = "password"

      client = CS::Client.new(base_uri: base_uri)
      user = client.new_user
      user.username = username
      user.email = user.username
      user.password = 'password'
      user.name = 'Jan'
      user.surname = 'jagger'
      user.address = 'Lloydstraat 5'
      user.zipcode = '3024ea'
      user.country = 'NETHERLANDS'
      user.mobile = '123456789'
      user
    end

    let!(:logged_in_client) do
      client = CS::Client.new(base_uri: base_uri)
      client.session_id = '1234'
      client
    end

    def get_attribute(user)
      {
        email: user.email,
        username: user.username,
        name: user.name,
        surname: user.surname,
        address: user.address,
        zipcode: user.zipcode,
        country: user.country,
        mobile: user.mobile,
        password: user.password
      }
    end

    it "create new user" do
      current_user = user
      body = {user: get_attribute(current_user)}
      stub_request(:post, base_uri + '/users.json').
                 with(:body => body).
                 to_return(:status => 201, :body => "", :headers => {
                   location: base_uri + '/users/1'
                 })

      user.save!.should be_true
      user.id.should == "1"
      current_user.id.should_not be_nil
    end

    it "should login the user" do
      client = create_client
      current_user = user
      stub_request(:post, base_uri + "/login.json").
                 with(:body => {username: current_user.username, password: current_user.password},
                      :headers => {'Content-Type'=>'application/json'}).
                 to_return(:status => 200, :body => {session_id: "1"}.to_json, :headers => {'Content-Type' => 'application/json'})

      session_id = client.login!(user.username, 'password')
      session_id.should == "1"
    end

    it "get user data from commonSense" do
      current_user = user
      attributes = get_attribute(current_user)

      body = {
        user: {
          id: "3357",
            email: current_user.email,
            username: current_user.username,
            name: current_user.name,
            surname: current_user.surname,
            address: current_user.address,
            zipcode: current_user.zipcode,
            country: current_user.country,
            mobile: current_user.mobile,
            UUID: "203a8-aa54-11e1-85e6-da0007d04f45",
            openid: nil
          }
      }

      stub_request(:get, "http://api.dev.sense-os.local/users/current.json?").
        with(:headers => {'Content-Type'=>'application/json', 'X-Session-Id'=>'1234'}).
        to_return(:status => 200, :body => body.to_json, :headers => {'Content-Type'=>'application/json'})

      client = logged_in_client
      current_user = client.current_user

      attributes.each do |key, value|
        next if key == :password
        current_user.send(key).should eq(value)
      end
    end

    it "update user" do
      expected = {
        email: "user-edit-1@tester.com",
        username: "user-edit-1@tester.com",
        name: "Jan Edit",
        surname: "jagger edit",
        address: 'Looydstraat 5 edit',
        zipcode: '12345',
        country: 'GERMANY',
        mobile: '987654321'
      }

      client = logged_in_client
      current_user = user
      current_user.id = "1"

      body = {user: expected}
      body[:user][:password] = current_user.password
      body[:user][:id] = current_user.id

      stub_request(:put, "http://api.dev.sense-os.local/users/1.json").
        with(:body => body,
             :headers => {'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => "", :headers => {})


      expected.each do |key, value|
        current_user.send("#{key}=".to_sym, value) unless key == :password
      end

      current_user.save!

      expected.each do |key,value|
        current_user.send(key).should eq(value)
      end

    end
  end
end
