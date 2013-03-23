require 'spec_helper'
require 'ostruct'

describe "Sensor Management" do

  describe "Manage Sensor" do
    before(:all) do
      @client = create_client
      @client.login($username, $password)
    end

    after(:all) do
      @client.sensors.each {|sensors| sensors.delete}
    end

    let(:sensor_info) do
      {
        name: "accelerometer",
        display_name: "Accelerometer",
        device_type: "BMA123",
        pager_type: "email",
        data_type: "json",
        data_structure: {"x-axis" => "Float", "y-axis" => "Float", "z-axis" => "Float"}
      }
    end

    def compare_to_sensor_info(sensor)
      sensor.name.should eq(sensor_info[:name])
      sensor.display_name.should eq(sensor_info[:display_name])
      sensor.display_name.should eq(sensor_info[:display_name])
      sensor.pager_type.should eq(sensor_info[:pager_type])
      sensor.data_type.should eq(sensor_info[:data_type])
      sensor.data_structure.should eq(sensor_info[:data_structure])
    end

    it "create a new sensor" do
      sensor = @client.sensors.build
      sensor.name = sensor_info[:name]
      sensor.display_name = sensor_info[:display_name]
      sensor.device_type = sensor_info[:display_name]
      sensor.pager_type = sensor_info[:pager_type]
      sensor.data_type = sensor_info[:data_type]
      sensor.data_structure = sensor_info[:data_structure]
      sensor.save!
    end

    it "get list of sensor from commonSense" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!

      @client.sensors.all.should_not be_empty

      # there could be another Virtual sensor that is automatically created
      @client.sensors.count.should be > 1

      @client.sensors.each do |sensor|
        compare_to_sensor_info(sensor)
        break
      end
    end

    it "get first sensor data" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!
      sensor = @client.sensors.first

      sensor.should_not be nil
      compare_to_sensor_info(sensor)
    end

    it "get sensor data by id" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!

      first = @client.sensors.first

      sensor = @client.sensors.find(first.id)
      sensor.should_not be_nil
    end


    it "filter sensor data" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!
      sensors = @client.sensors.where(page: 0, per_page: 1, owned: true , details: true)
      sensors.to_a.should_not be_empty
    end

    it "should handle pagination" do
      2.times do
        sensor = @client.sensors.build(sensor_info)
        sensor.save!
      end

      count = @client.sensors.count

      i = 0;
      @client.sensors.where(per_page: 1).each do
        i += 1
      end

      i.should eq(count)
    end
  end
end
