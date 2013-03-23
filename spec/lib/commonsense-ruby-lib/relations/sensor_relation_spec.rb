require 'spec_helper'
require 'commonsense-ruby-lib/sensor'

module CommonSense
describe CommonSense::SensorRelation do

  describe "build" do
    it "should return a sensor object" do
      CommonSense::SensorRelation.new.build.should be_a_kind_of(CommonSense::Sensor)
    end
  end

  let(:sensors) {
    {"sensors" => [{"name" => "sensor1"}, {"name" => "sensor2"}, {"name" => "sensor3"}], "total" => 3}
  }

  let(:relation) {
    relation = SensorRelation.new
    relation.stub("check_session!").and_return(true)
    relation.stub("get_sensor").and_return(sensors)
    relation
  }

  describe "each" do
    it "should get all sensor and yield each" do
      relation = SensorRelation.new
      relation.stub("get_sensor").and_return(sensors)

      expect { |b| relation.each(&b) }.to yield_successive_args(Sensor, Sensor, Sensor)
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
      first.should be_kind_of(Sensor)
      first.name.should eq("sensor1")
    end
  end

  describe "last" do
    it "should return the last record" do
      relation = SensorRelation.new
      relation.stub("count").and_return(3)
      relation.should_receive("get_sensor").with(page:2, per_page:1, shared:nil, owned:nil, physical:nil, details:nil).and_return({"sensors" => [{"name" => "sensor3"}], "total" => 3})

      first = relation.last
      first.should be_kind_of(Sensor)
      first.name.should eq("sensor3")
    end
  end

  describe "get_sensor!" do
    it "should fetch sensor list from commonSense" do
      session = double('Session')
      option = {page: 100, per_page: 99, shared: 1, owned:1, physical: 1, details: "full"}
      session.should_receive(:get).with("/sensors.json", option)

      relation = SensorRelation.new(session)
      relation.get_sensor!(page: 100, per_page: 99, shared:true, owned:true, physical:true, details:"full")
    end
  end

  describe "get_sensor" do
    it "should not throw an exception" do
      relation = SensorRelation.new
      relation.stub(:get_sensor!).and_return { raise Error }

      expect { relation.get_sensor}.to_not raise_error
    end
  end

  describe "where" do
    it "should update the query parameter" do
      relation = SensorRelation.new
      relation.where(page:0, per_page:10, shared: true, owned:true, physical: true, details: "full")
      relation.page.should eq(0)
      relation.per_page.should eq(10)
      relation.shared.should eq(1)
      relation.owned.should eq(1)
      relation.physical.should eq(1)
      relation.details.should eq("full")

      relation.where(page:0, per_page:10, shared: false, owned:false, physical: false, details: "no")
      relation.page.should eq(0)
      relation.per_page.should eq(10)
      relation.shared.should eq(0)
      relation.owned.should eq(0)
      relation.physical.should eq(0)
      relation.details.should eq("no")

      relation.where(page:nil, per_page:nil, shared: nil, owned:nil, physical: nil, details: nil)
      relation.page.should eq(0)
      relation.per_page.should eq(10)
      relation.shared.should be_nil
      relation.owned.should be_nil
      relation.physical.should be_nil
      relation.details.should eq("no")
    end
  end
end
end
