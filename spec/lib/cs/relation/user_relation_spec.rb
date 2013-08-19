require 'spec_helper'
require 'cs/end_point/user'

module CS
  module Relation
    describe UserRelation do
      let(:users) {
        {"users" => [{"name" => "user1"}, {"name" => "user2"}, {"name" => "user3"}], "total" => 3}
      }

      let(:relation) {
        relation = UserRelation.new
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data!").and_return(users)
        relation
      }

      describe "get_data!" do
        it "should fetch sensor data from commonSense" do
          session = double('Session')
          option = {page: 100, per_page: 99}
          session.should_receive(:get).with("/users.json", option)

          relation = UserRelation.new(session)
          relation.get_data!(page: 100, per_page: 99)
        end
      end

      describe "each" do
        it "should get all user and yield each" do
          session = double('Session')
          relation = UserRelation.new(session)
          relation.stub("get_data!").and_return(users)

          expect { |b| relation.each(&b) }.to yield_successive_args(EndPoint::User, EndPoint::User, EndPoint::User)
        end

        context "empty result" do
          it "should not yield control" do
            session = double('Session')
            relation = UserRelation.new(session)
            relation.stub("get_data!").and_return({"users" => [], "total" => 0})

            expect { |b| relation.each(&b) }.not_to yield_control
          end
        end

        context "limit specified" do
          it "should yield sensor at most specified by limit" do
            relation.limit(1).to_a.count.should eq(1)
          end
        end
      end


      describe "last" do
        it "should return the last record" do
          relation = SensorRelation.new
          relation.stub("count").and_return(3)
          relation.should_receive("get_data").with(page:2, per_page:1).and_return({"sensors" => [{"name" => "sensor3"}], "total" => 3})

          first = relation.last
          first.should be_kind_of(EndPoint::Sensor)
          first.name.should eq("sensor3")
        end

        context "with parameters given" do
          it "should return the last record with options" do
            relation = SensorRelation.new
            relation.stub("count").and_return(3)
            relation.should_receive("get_data").with(page:2, per_page:1, shared:1, owned:1, physical:1, details:'full').and_return({"sensors" => [{"name" => "sensor3"}], "total" => 3})

            first = relation.where(shared: true, owned: true, physical:true, details: 'full').last
            first.should be_kind_of(EndPoint::Sensor)
            first.name.should eq("sensor3")
          end
        end
      end
    end
  end
end
