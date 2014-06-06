require 'spec_helper'

module CS
  module EndPoint
    describe Sensor do

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

          session = double("CS::Session")
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

          session = double("CS::Session")
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

          session = double("CS::Session")
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

          session = double("CS::Session")
          session.should_receive(:delete).with("/sensors/#{sensor_id}.json")
          session.stub(:response_code => 200)
          sensor.session = session

          sensor.delete!.should be_true
        end
      end

      describe "copy_data" do
        it "should copy data from other sensor" do
          # create sensor_a
          session_a = CS::Session.new
          session_a.session_id = 1
          sensor_a = Sensor.new(id: 1)
          sensor_a.session = session_a

          # create sensor_b
          session_b = CS::Session.new
          session_b.session_id = 2
          sensor_b = Sensor.new(id: 2)
          sensor_b.session = session_b

          # session_a should recice get with parameter corrent start_date and end_date
          data = {"data" => [{"id"=>"1_1401381426.400", "sensor_id"=>1, "value"=> "1", "date"=>1402032192.4}]}
          session_a.should_receive(:get)
            .with("/sensors/1/data.json", {:page=>0, :per_page=>1000, :start_date=>1402032192.0, :end_date=>1402032200.0, sensor_id: 1})
            .and_return(data)

          # session_b should receive post with data
          session_b.should_receive(:post)
            .with("/sensors/data.json", {:sensors=>[{:sensor_id=>2, :data=>[{:date=>1402032192.4, :value=>"1"}]}]})
          sensor_b.copy_data(sensor_a, start_date: 1402032192, end_date: 1402032200)

        end
      end
    end
  end
end
