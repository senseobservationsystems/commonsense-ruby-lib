require 'spec_helper'
require 'webmock/rspec'

describe "User management" do

  describe "Manage user" do

    let(:base_uri) do
      ENV['spec_base_uri']
    end

    let!(:user) do
      username = "user#{Time.now.to_f}@tester.com"
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

    def get_attribute(user)
      {
        user: {
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
      }
    end

    it "create new user" do
      current_user = user
      stub_request(:post, base_uri + 'users.json').
                 with(:body => get_attribute(current_user)).
                 to_return(:status => 201, :body => "", :headers => {
                   location: base_uri + 'users/1'
                 })

      user.save!.should be_true
      user.id.should == "1"
      current_user.id.should_not be_nil
    end

    it "should login the user" do
      client = create_client
      current_user = user
      stub_request(:post, "http://192.168.33.10/login.json").
                 with(:body => {username: current_user.username, password: current_user.password},
                      :headers => {'Content-Type'=>'application/json'}).
                 to_return(:status => 200, :body => {session_id: "1"}.to_json, :headers => {'Content-Type' => 'application/json'})

      session_id = client.login!(user.username, 'password')
      session_id.should == "1"
    end

    xit "get user data from commonSense" do
      attributes = get_attribute(current_user)

      client = create_client
      current_user = client.current_user

      attributes.each do |key, value|
        next if key == :password
        current_user.send(key).should eq(value)
      end
    end

    xit "update user" do
      current_time = Time.now.to_f
      client = create_client
      username = "user-#{current_time}@tester.com"
      current_user = client.new_user(username: username, email: username, password: 'password')
      current_user.save!
      current_user.id.should_not be_nil

      expected = { username: "user-edit-#{current_time}@tester.com",
        email: "user-edit-#{current_time}@tester.com",
        name: "Jan Edit",
        surname: "jagger edit",
        address: 'Looydstraat 5 edit',
        zipcode: '12345',
        country: 'GERMANY',
        mobile: '987654321'
      }

      client = create_client
      client.session.should be_nil
      session_id = client.login(current_user.username, 'password')
      session_id.should_not be_nil
      client.session.should_not be_nil

      current_user = client.current_user

      expected.each do |key, value|
        current_user.send("#{key}=".to_sym, value)
      end

      current_user.save!
      current_user.reload

      expected.each do |key,value|
        current_user.send(key).should eq(value)
      end

    end
  end
end
