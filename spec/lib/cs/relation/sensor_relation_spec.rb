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

      describe "each" do
        it "should get all sensor and yield each" do
          session = double('Session')
          relation = SensorRelation.new(session)
          relation.stub("get_data!").and_return(sensors)

          expect { |b| relation.each(&b) }.to yield_successive_args(EndPoint::Sensor, EndPoint::Sensor, EndPoint::Sensor)
        end

        context "empty result" do
          it "should not yield control" do
            session = double('Session')
            relation = SensorRelation.new(session)
            relation.stub("get_data!").and_return({"sensors" => [], "total" => 0})

            expect { |b| relation.each(&b) }.not_to yield_control
          end
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

      describe "find_by_name" do
        before(:each) do
          @relation = SensorRelation.new
          @relation.session = double('Session')
          @relation.stub("count").and_return(3)
          @relation.should_receive("get_data!").with(page:0, per_page:1000).and_return({"sensors" => [{"name" => "sensor11"}, {"name" => "sensor12"}, {"name" => "sensor2"}], "total" => 3})
        end

        it "should return an array of matching sensor name by string" do
          sensors = @relation.find_by_name("sensor11")
          sensors.should be_kind_of(Array)
          sensors.size.should eq(1)
          sensors[0].name.should eq("sensor11")
        end

        it "should return an array of matching sensor by regex" do
          sensors = @relation.find_by_name(/.*sor1/)
          sensors.should be_kind_of(Array)
          sensors.size.should eq(2)
          sensors[0].name.should eq("sensor11")
          sensors[1].name.should eq("sensor12")
        end
      end

      describe "find_or_new" do
        context "there is already sensor matching criteria" do
          it "should return that sensor" do
            relation = SensorRelation.new
            relation.session = double('Session')
            relation.stub("count").and_return(1)
            relation.should_receive("get_data!").with(page:0, per_page:1000).and_return({"sensors" => [{
              id: "143353",
              name: "sensor1",
              type: "1",
              device_type: "Android",
              pager_type: "pager1",
              display_name: "Sensor1",
              data_type: "json",
              data_structure: "{\"foo\": \"integer\"}"
            }], "total" => 1})

            attributes = {name: 'sensor1', display_name: 'Sensor1',
              device_type: 'Android', pager_type: 'pager1',
              data_type: 'json', data_structure: {"foo" => 'integer'}}

            sensor = relation.find_or_new(attributes)
            sensor.should be_kind_of(EndPoint::Sensor)
            sensor.id.should_not be_nil
            attributes.each do |key, value|
              sensor.parameter(key).should eq(value)
            end
          end
        end

        context "there is no sensor matching criteria" do
          it "should return new sensor object" do
            attributes = {name: 'sensor1', display_name: 'Sensor1',
              device_type: 'Android', pager_type: 'pager1',
              data_type: 'json', data_structure: {"foo" => 'integer'}}

            relation.session = double('session')
            sensor = relation.find_or_new(attributes)
            sensor.should be_kind_of(EndPoint::Sensor)
            sensor.session.should_not be_nil
            sensor.id.should be_nil
            attributes.each do |key, value|
              sensor.parameter(key).should eq(value)
            end
          end
        end
      end

      describe "find_or_create" do
        context "there is no sensor matching criteria" do
          it "should return create sensor object" do
            attributes = {name: 'sensor1', display_name: 'Sensor1',
              device_type: 'Android', pager_type: 'pager1',
              data_type: 'json', data_structure: {"foo" => 'integer'}}

            expected = EndPoint::Sensor.new(attributes)
            expected.should_receive(:save!)
            relation.stub('find_or_new').and_return(expected)

            sensor = relation.find_or_create!(attributes)
            sensor.should be_kind_of(EndPoint::Sensor)
            attributes.each do |key, value|
              sensor.parameter(key).should eq(value)
            end
          end
        end
      end

      describe "clone_from" do
        it "should copy properties from other sensor and assign the session_id" do
            attributes = {name: 'sensor1', display_name: 'Sensor1',
              device_type: 'Android', pager_type: 'pager1',
              data_type: 'json', data_structure: {"foo" => 'integer'}}

            source = EndPoint::Sensor.new(attributes)
            cloned = relation.clone_from(source)

            cloned.name.should eq(attributes[:name])
            cloned.display_name.should eq(attributes[:display_name])
            cloned.device_type.should eq(attributes[:device_type])
            cloned.pager_type.should eq(attributes[:pager_type])
            cloned.data_type.should eq(attributes[:data_type])
            cloned.data_structure.should eq(attributes[:data_structure])
        end
      end
    end
  end
end
