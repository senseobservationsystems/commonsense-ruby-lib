require 'spec_helper'

module CommonSense
  module EndPoint
    describe SensorData do

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

      describe "Initiating new sensor" do
        it "should assign the data point property on initialize" do
          info = sensor_info
          info[:id] = 1
          sensor = Sensor.new(info)
          sensor.id.should eq(1)
          sensor.name.should eq(info[:name])
          sensor.display_name.should eq(info[:display_name])
          sensor.device_type.should eq(info[:device_type])
          sensor.pager_type.should eq(info[:pager_type])
          sensor.data_type.should eq(info[:data_type])
          sensor.data_structure.should eq(info[:data_structure])
        end
      end

      describe "Creating" do
        it "should POST to /sensors.json" do
          sensor = Sensor.new(sensor_info)

          session = double("CommonSense::Session")
          expected = {sensor: sensor_info }
          expected[:sensor][:data_structure] = (sensor_info[:data_structure].to_json)
          session.should_receive(:post).with("/sensors.json", expected)
          session.stub(:response_headers => {"location" => "http://foo.bar/sensors/1"})
          session.stub(:response_code => 201)
          sensor.session = session

          sensor.save!.should be_true
        end
      end

      describe "Get specific data point" do
        it "should request GET to /sensors/:id.json" do
          sensor = Sensor.new(sensor_info)
          sensor_id = 1
          sensor.id = sensor_id

          session = double("CommonSense::Session")
          session.should_receive(:get).with("/sensors/#{sensor_id}.json")
          session.stub(:response_code => 200)
          sensor.session = session

          sensor.retrieve!.should be_true
        end
      end

      describe "Update specific data point" do
        it "should request data point from commonSense" do
          sensor = Sensor.new(sensor_info)
          sensor_id = 1
          sensor.id = sensor_id

          session = double("CommonSense::Session")
          expected = {sensor: sensor_info }
          expected[:sensor][:data_structure] = (sensor_info[:data_structure].to_json)
          expected[:sensor][:id] = 1
          session.should_receive(:put).with("/sensors/#{sensor_id}.json", expected)
          session.stub(:response_code => 200)
          sensor.session = session

          sensor.save!.should be_true
        end
      end

      describe "Delete specific data point" do
        it "should perform DELETE request to commonSense" do
          sensor = Sensor.new(sensor_info)
          sensor_id = 1
          sensor.id = sensor_id

          session = double("CommonSense::Session")
          session.should_receive(:delete).with("/sensors/#{sensor_id}.json")
          session.stub(:response_code => 200)
          sensor.session = session

          sensor.delete!.should be_true
        end
      end
    end
  end
end
