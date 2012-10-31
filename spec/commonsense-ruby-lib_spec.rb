require 'spec_helper'

describe "commonsense-ruby-lib" do
  describe "client" do
    shared_examples_for "Client" do
      describe "current_user", :vcr do
        it "should return current user information" do
          current_user = @client.current_user
          current_user.username.should eq('a')
        end
      end

      describe "groups", :vcr do
        it "should return groups that current user belongs to" do
          groups = @client.current_groups
          groups.should_not be_empty
        end
      end
    end

    describe "with session_id" do
      before(:each) do
        @client = client = CommonSense::Client.new
        @session_id = @client.login(CONFIG['CS_USER'], CONFIG['CS_PASSWORD'])
        @session_id.should_not be_nil
      end

      it_behaves_like "Client"
    end

    describe "with OAuth" do
      before(:each) do
        @client = client = CommonSense::Client.new
        @client.oauth(CONFIG['CS_CONSUMER_KEY'], CONFIG['CS_CONSUMER_SECRET'],
                                CONFIG['CS_ACCESS_TOKEN'], CONFIG['CS_ACCESS_TOKEN_SECRET'])
      end

      it_behaves_like "Client"
    end
  end
end
