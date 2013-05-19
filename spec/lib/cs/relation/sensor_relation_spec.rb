require 'spec_helper'
require 'cs/end_point/sensor'

module CS
  module Relation
    describe SensorRelation do
      describe "build" do
        it "should return a sensor object" do
          SensorRelation.new.build.should be_a_kind_of(EndPoint::Sensor)
        end
      end

      let(:sensors) {
        {"sensors" => [{"name" => "sensor1"}, {"name" => "sensor2"}, {"name" => "sensor3"}], "total" => 3}
      }

      let(:relation) {
        relation = SensorRelation.new
        relation.stub("check_session!").and_return(true)
        relation.stub("get_data!").and_return(sensors)
        relation
      }

      describe "get_data!" do
        it "should fetch sensor data from commonSense" do
          session = double('Session')
          option = {page: 100, per_page: 99, shared: 1, owned:1, physical: 1, details: "full"}
          session.should_receive(:get).with("/sensors.json", option)

          relation = SensorRelation.new(session)
          relation.get_data!(page: 100, per_page: 99, shared:true, owned:true, physical:true, details:"full")
        end
      end

      describe "get_data" do
        it "should not throw an exception" do
          relation = SensorRelation.new
          relation.stub(:get_data!).and_return { raise Error }

          expect { relation.get_data }.to_not raise_error
        end
      end

      describe "each" do
        it "should get all sensor and yield each" do
          relation = SensorRelation.new
          relation.stub("get_data!").and_return(sensors)

          expect { |b| relation.each(&b) }.to yield_successive_args(EndPoint::Sensor, EndPoint::Sensor, EndPoint::Sensor)
        end

        context "limit specified" do
          it "should yield sensor at most specified by limit" do
            relation.limit(1).to_a.count.should eq(1)
          end
        end
      end

      describe "count" do
        it "should return the total number of record" do
          relation.count.should eq(3)
        end
      end

      describe "first" do
        it "should return the first record" do
          first = relation.first
          first.should be_kind_of(EndPoint::Sensor)
          first.name.should eq("sensor1")
        end
      end

      describe "last" do
        it "should return the last record" do
          relation = SensorRelation.new
          relation.stub("count").and_return(3)
          relation.should_receive("get_data").with(page:2, per_page:1, shared:nil, owned:nil, physical:nil, details:nil).and_return({"sensors" => [{"name" => "sensor3"}], "total" => 3})

          first = relation.last
          first.should be_kind_of(EndPoint::Sensor)
          first.name.should eq("sensor3")
        end
      end

      describe "find_by_name" do
        it "should return an array of matching sensor name" do
          relation = SensorRelation.new
          relation.session = double('Session')
          relation.stub("count").and_return(3)
          relation.should_receive("get_data!").with(page:0, per_page:1000).and_return({"sensors" => [{"name" => "sensor11"}, {"name" => "sensor12"}, {"name" => "sensor2"}], "total" => 3})

          sensors = relation.find_by_name(/sensor1/)
          sensors.should be_kind_of(Array)
          sensors.size.should eq(2)
          sensors[0].name.should eq("sensor11")
          sensors[1].name.should eq("sensor12")
        end
      end
    end
  end
end
