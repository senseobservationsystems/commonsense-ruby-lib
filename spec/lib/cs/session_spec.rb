require 'spec_helper'
require 'logger'
require 'webmock/rspec'

describe "session" do

  let!(:user) do
    username = "user1@tester.com"

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

  describe "login" do
    describe "with corrent username and password" do
      it "should create new session" do
        client = create_client
        CS::Auth::HTTP.any_instance.stub(login: "1234")
        session_id = client.login!(user.username, 'password')
        session_id.should_not be_nil
        client.session.should_not be_nil
      end
    end

    describe "with incorrect username or password" do
      it "should create new session" do
        client = create_client
        CS::Auth::HTTP.any_instance.stub(login: false)
        session_id = client.login(user.username, "foo")
        session_id.should be_false
        client.session.should_not be_nil
      end
    end
  end

  describe "logger" do
    context "Debug level given" do
      it "should write to logger (STDOUT)" do
        client = create_client
        client.login(user.username, 'password')

        CS::Auth::HTTP.any_instance.stub(get: "")

        session = client.session
        logger = double().as_null_object
        session.logger = logger
        logger.should_receive("info").with("").ordered
        logger.should_receive("info").with("GET /users/current.json").ordered
        logger.should_receive("debug").with("headers: {}").ordered
        session.get('/users/current.json', '',{})
      end
    end
  end

  describe "oauth" do
    describe "with correct access token" do
       it "should create new session with oauth" do
         client = create_client
         CS::Auth::OAuth.should_receive(:new).with('CS_CONSUMER_KEY', 'CS_CONSUMER_SECRET',
                                'CS_ACCESS_TOKEN', 'CS_ACCESS_TOKEN_SECRET', base_uri)
         client.oauth('CS_CONSUMER_KEY', 'CS_CONSUMER_SECRET',
                                'CS_ACCESS_TOKEN', 'CS_ACCESS_TOKEN_SECRET')
       end
    end
  end

  describe "API_KEY" do
    it "should append API key in the url" do
      client = create_client
      client.api_key = '123456'
      CS::Auth::HTTP.should_receive(:get).
        with("http://api.dev.sense-os.local/sensors.json?API_KEY=123456",
             {:query=>{:page=>0, :per_page=>1000},
              :headers=>{"Content-Type"=>"application/json"}}
            )

      result = client.sensors
      result.to_a
    end
  end
end
