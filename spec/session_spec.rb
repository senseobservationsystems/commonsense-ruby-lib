require 'spec_helper'

describe "session" do
  before(:each) do
    @client = client = CommonSense::Client.new
  end

  describe "login" do
    describe "with corrent username and password" do
      it "should create new session", :vcr do
        session_id = @client.login(CONFIG['CS_USER'], CONFIG['CS_PASSWORD'])
        session_id.should_not be_nil
        @client.session.should_not be_nil
        @client.session.response_code.should eq(200)
        @client.session.session_id.should_not be_nil
      end
    end

    describe "with incorrect username or password" do
      it "should create new session", :vcr do
        session_id = @client.login(CONFIG['CS_USER'], "x#{CONFIG['CS_PASSWORD']}")
        session_id.should be_nil
        @client.session.should_not be_nil
        @client.session.response_code.should eq(403)
        @client.session.session_id.should be_nil
      end
    end
  end

  describe "oauth" do
    describe "with correct access token", :vcr do
       it "should create new session with oauth" do
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
