require 'spec_helper'

describe "commonsense-ruby-lib" do
  describe "client with authentication" do
    before(:each) do
      @client = client = create_client
      @session_id = @client.login($user.username, 'password')
      @session_id.should_not be_nil
    end

    describe "current_user" do
      it "should return current user information" do
        current_user = @client.current_user
        current_user.username.should eq($user.username)
        current_user.to_h.should be_kind_of Hash
      end
    end

    describe "groups" do
      it "should return groups that current user belongs to" do
        groups = @client.current_groups
        groups.should be_empty
      end
    end

    describe "new_user" do
      it "should create a new user" do

      end
    end

    describe "sensors" do
      it "should return Sensors relation" do
        @client.sensors.should be_a_kind_of(CommonSense::SensorRelation)
      end
    end
  end

  describe "with session_id" do
  end

  describe "with OAuth" do
    before(:each) do
      @client = client = CommonSense::Client.new
      @client.oauth(CONFIG['CS_CONSUMER_KEY'], CONFIG['CS_CONSUMER_SECRET'],
                    CONFIG['CS_ACCESS_TOKEN'], CONFIG['CS_ACCESS_TOKEN_SECRET'])
    end

    #it_behaves_like "Client"
  end
end
