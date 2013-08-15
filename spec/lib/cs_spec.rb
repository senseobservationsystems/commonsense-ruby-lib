require 'spec_helper'

module CS
  describe Client do
    describe "client with authentication" do
      let(:client) do
        create_client
      end

      let!(:logged_in_client) do
        client = CS::Client.new(base_uri: base_uri)
        client.set_session_id("1234")
        client
      end

      describe "current_user" do
        it "should return current user information" do
          user = EndPoint::User.new
          EndPoint::User.any_instance.stub(current_user: user)
          current_user = client.current_user
          current_user.should == user
          current_user.to_h.should be_kind_of Hash
        end
      end

      describe "groups" do
        it "should return groups that current user belongs to" do
          groups = [ EndPoint::Group.new ]
          EndPoint::Group.any_instance.stub(current_groups: groups)
          groups = logged_in_client.current_groups
          groups.should_not be_empty
        end
      end

      describe "new_user" do
        it "should create a new user" do

        end
      end

      describe "sensors" do
        it "should return Sensors relation" do
          client.sensors.should be_a_kind_of(CS::Relation::SensorRelation)
        end
      end
    end
  end
end
