require 'spec_helper'
require 'commonsense-ruby-lib/sensor'

module CommonSense
describe SensorRelation do
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
    relation.stub("get_data").and_return(sensors)
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

      expect { relation.get_data}.to_not raise_error
    end
  end

  describe "each" do
    it "should get all sensor and yield each" do
      relation = SensorRelation.new
      relation.stub("get_data").and_return(sensors)

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
      relation.should_receive("get_data").with(page:2, per_page:1, shared:nil, owned:nil, physical:nil, details:nil).and_return({"sensors" => [{"name" => "sensor3"}], "total" => 3})

      first = relation.last
      first.should be_kind_of(Sensor)
      first.name.should eq("sensor3")
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
      relation.per_page.should eq(1000)
      relation.shared.should be_nil
      relation.owned.should be_nil
      relation.physical.should be_nil
      relation.details.should be_nil

      relation.page = 100
      expect { relation.where(page: 'a') }.to raise_error ArgumentError

      relation.per_page = 999
      expect { relation.where(per_page: 'a') }.to raise_error ArgumentError

      relation.shared = false
      relation.where(shared: "true")
      relation.shared.should be_true

      relation.shared = false
      relation.where(shared: 1)
      relation.shared.should be_true

      relation.shared = true
      relation.where(shared: 0)
      relation.shared.should eq(0)

      relation.shared = true
      relation.where(shared: false)
      relation.shared.should eq(0)

      relation.shared = true
      relation.where(shared: "false")
      relation.shared.should eq(0)

      relation.details = nil
      relation.where(details: "no")
      relation.details.should eq("no")

      relation.details = nil
      relation.where(details: "full")
      relation.details.should eq("full")

      relation.details = nil
      expect { relation.where(details: 1) }.to raise_error ArgumentError


      relation.details = nil
      expect { relation.where(details: false) }.to raise_error ArgumentError
    end
  end
end
end
