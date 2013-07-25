require 'spec_helper'

module CS
  module EndPoint
    describe Sensor do

      let(:group_info) do
        {
          name: "group1",
          anonymous: false,
          public: true,
          hidden: false,
          description: "Description of group1",
          required_sensors: ["Location", "position"],
          default_list_users: true,
          default_add_users: true,
          default_remove_users: true,
          default_list_sensors: true,
          default_add_sensors: true,
          required_show_id: true,
          required_show_email: true,
          required_show_first_name: true,
          required_show_surname: true,
          required_show_phone_number: true,
          required_show_username: true
        }
      end

      describe "Initiating new sensor" do
        it "should assign the group property on initialize" do
          info = group_info
          info[:id] = 1
          group = Group.new(info)
          group.id.should eq(1)
          group.name.should eq("group1")
          group.anonymous.should be_false
          group.public.should be_true
          group.hidden.should be_false
          group.description.should eq("Description of group1")
          group.required_sensors.should eq(["Location", "position"])
          group.default_list_users.should be_true
          group.default_add_users.should be_true
          group.default_remove_users.should be_true
          group.default_list_sensors.should be_true
          group.default_add_sensors.should be_true
          group.required_show_id.should be_true
          group.required_show_email.should be_true
          group.required_show_first_name.should be_true
          group.required_show_surname.should be_true
          group.required_show_phone_number.should be_true
          group.required_show_username.should be_true
        end
      end

      describe "Creating" do
        it "should POST to /groups.json" do
          group = Group.new(group_info)

          session = double("CS::Session")
          expected = {group: group_info }
          session.should_receive(:post).with("/groups.json", expected)
          session.stub(:response_headers => {"location" => "http://foo.bar/groups/1"})
          session.stub(:response_code => 201)
          group.session = session

          group.save!.should be_true
        end
      end

      describe "Get specific data point" do
        it "should request GET to /groups/:id.json" do
          group = Group.new(group_info)
          group_id = 1
          group.id = group_id

          session = double("CS::Session")
          session.should_receive(:get).with("/groups/#{group_id}.json")
          session.stub(:response_code => 200)
          group.session = session

          group.retrieve!.should be_true
        end
      end

      describe "Update specific group point" do
        it "should request data point from commonSense" do
          group = Group.new(group_info)
          group_id = 1
          group.id = group_id
          group.name = "group 1 edit"

          session = double("CS::Session")
          expected = {group: group_info }
          expected[:group][:name] = "group 1 edit"
          expected[:group][:id] = 1
          session.should_receive(:put).with("/groups/#{group_id}.json", expected)
          session.stub(:response_code => 200)
          group.session = session

          group.save!.should be_true
        end
      end

      describe "Delete specific data point" do
        it "should perform DELETE request to commonSense" do
          group = Group.new(group_info)
          group_id = 1
          group.id = group_id

          session = double("CS::Session")
          session.should_receive(:delete).with("/groups/#{group_id}.json")
          session.stub(:response_code => 200)
          group.session = session

          group.delete!.should be_true
        end
      end
    end
  end
end
