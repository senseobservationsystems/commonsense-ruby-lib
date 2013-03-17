require 'spec_helper'
require 'ostruct'

describe "Sensor Management" do

  describe "Manage Sensor" do
    before(:all) do
      @client = create_client
      @client.login($username, $password)
    end

    let(:sensor_info) do
      sensor_info = OpenStruct.new
      sensor_info.name = "accelerometer"
      sensor_info.display_name = "Accelerometer"
      sensor_info.display_name = "BMA123"
      sensor_info.pager_type = "email"
      sensor_info.data_type = "json"
      sensor_info.data_structure = {"x-axis" => Float, "y-axis" => Float, "z-axis" => Float}
      sensor_info
    end

    it "create a new sensor" do
      sensor = @client.sensors.build
      sensor.name = sensor_info.name
      sensor.display_name = sensor_info.display_name
      sensor.device_type = sensor_info.display_name
      sensor.pager_type = sensor_info.pager_type
      sensor.data_type = sensor_info.data_type
      sensor.data_structure = sensor_info.data_structure
      binding.pry
      sensor.save!
    end

    it "get list of sensor from commonSense" do
      @client.sensors.all

      @client.sensor.each do |sensor|
        sensor.name.should eq(sensor_info.name)
        sensor.display_name.should eq(sensor_info.display_name)
        sensor.display_name.should eq(sensor_info.display_name)
        sensor.pager_type.should eq(sensor_info.pager_type)
        sensor.data_type.shoudl eq(sensor_info.data_type)
        sensor.data_structure.should eq(sensor_info.data_structure)
      end

      @client.sensors.count.should eq(1)
    end

    it "get first sensor data" do
      sensor = @client.sensors.first
      sensor.should_no be nil
    end

    it "get sensor data by id" do
      first = @client.sensors.first
      sensor = @client.sensors.find(first.id)
      sensor.should_not be_nil
    end

    it "get last sensor data" do
      sensor = @client.sensors.last
      sensor.should_not be_nil
    end


    it "filter sensor data" do
      sensors = @client.sensors.where(owned: true, pysical: true, details: true)
      sensors.should_not be_empty
    end

    it "update sensor information" do
      sensor = @client.sensors.first

      sensor.name = "Name edit"
      sensor.display_name = "Display Name Edit"
      sensor.display_name = "Type Edit"
      sensor.pager_type = "Pager Type Edit"
      sensor.data_type = Integer
      sensor.save

      sensor.reload

      sensor.name.should eq("Name edit")
      sensor.display_name.should eq("Display Name Edit")
      sensor.display_name.should eq("Type Edit")
      sensor.pager_type.should eq("Pager Type Edit")
      sensor.data_type.should eq(Integer)
      sensor.data_structure.should eq("1")
    end

    it "delete sensor" do
      sensor = @client.sensor.first
      sensor.delete

      @client.sensors.all.should be_empty
    end

    it "should handle pagination" do
      2.times.do { create_sensor }

      i = 0;
      @client.sensors.where(per_page: 1).each do
        i += 1
      end

      i.should eq(2)
    end
  end
end
