require 'spec_helper'

describe "session" do
  before(:each) do
    @client = client = CS::Client.new(base_uri: ENV['spec_base_uri'])
  end

  describe "login" do
    describe "with corrent username and password" do
      it "should create new session" do
        session_id = @client.login($user.username, 'password')
        session_id.should_not be_nil
        @client.session.should_not be_nil
        @client.session.response_code.should eq(200)
        @client.session.session_id.should_not be_nil
      end
    end

    describe "with incorrect username or password" do
      it "should create new session", :vcr do
        session_id = @client.login($user.username, "x#{$user.password}")
        session_id.should be_nil
        @client.session.should_not be_nil
        @client.session.response_code.should eq(403)
        @client.session.session_id.should be_nil
      end
    end
  end

  describe "oauth" do
    describe "with correct access token" do
       it "should create new session with oauth" do
         pending
         session = @client.oauth(CONFIG['CS_CONSUMER_KEY'], CONFIG['CS_CONSUMER_SECRET'],
                                CONFIG['CS_ACCESS_TOKEN'], CONFIG['CS_ACCESS_TOKEN_SECRET'])
         session.should be_true
         @client.current_user.should_not be_nil
         @client.session.response_code.should eq(200)
         @client.session.response_body.should_not be_nil
       end
    end
  end
end
