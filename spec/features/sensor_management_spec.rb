require 'spec_helper'
require 'ostruct'
require 'webmock/rspec'

describe "Sensor Management" do

  describe "Manage Sensor" do

    let(:sensor_info) do
      {
        name: "accelerometer",
        display_name: "Accelerometer",
        device_type: "BMA123",
        pager_type: "email",
        data_type: "json",
        data_structure: {"x-axis" => "Float", "y-axis" => "Float", "z-axis" => "Float"}.to_json
      }
    end

    let!(:logged_in_client) do
      client = CS::Client.new(base_uri: base_uri)
      client.set_session_id("1234")
      client
    end

    let(:response_list_sensors) do
      {
        sensors: [
          {
            id: "143353",
            name: "light",
            type: "1",
            device_type: "CM3602 Light sensor",
            pager_type: "",
            display_name: "light",
            use_data_storage: true,
            data_type: "json",
            data_structure: "{\"lux\":\"Integer\"}",
            device: {
              id: "5492",
              type: "HTC One V",
              uuid: "351816053990044"
            }
          },
          {
            id: "143354",
            name: "noise_sensor",
            type: "1",
            device_type: "noise_sensor",
            pager_type: "",
            display_name: "noise",
            use_data_storage: true,
            data_type: "float",
            data_structure: "",
            device: {
              id: "5492",
              type: "HTC One V",
              uuid: "351816053990044"
            }
          },
          {
            id: "143355",
            name: "Availability",
            type: "2",
            device_type: "2",
            pager_type: "",
            display_name: "",
            use_data_storage: true,
            data_type: "string",
            data_structure: ""
          }
        ]
      }
    end

    def compare_to_sensor_info(a, b)
      a.name.should eq(b[:name])
      a.display_name.should eq(b[:display_name])
      a.display_name.should eq(b[:display_name])
      a.pager_type.should eq(b[:pager_type])

      parsed_structure = b[:data_structure]
      if !b[:data_structure].empty?
        parsed_structure = JSON.parse(parsed_structure)
      end

      a.data_structure.should eq(parsed_structure)
      a.data_type.should eq(b[:data_type])
    end

    it "create a new sensor" do
      body = {sensor: sensor_info}

      stub_request(:post, "http://api.dev.sense-os.local/sensors.json").
        with(:body => body,
             :headers => {'Content-Type'=>'application/json', 'X-Session-Id'=>'1234'}).
        to_return(:status => 201, :body => "", :headers => {
               location: base_uri + '/sensors/1'
             })

      sensor = logged_in_client.sensors.build
      sensor.name = sensor_info[:name]
      sensor.display_name = sensor_info[:display_name]
      sensor.device_type = sensor_info[:device_type]
      sensor.pager_type = sensor_info[:pager_type]
      sensor.data_type = sensor_info[:data_type]
      sensor.data_structure = sensor_info[:data_structure]
      sensor.save!.should be_true

      sensor.id.should == "1"
    end

    it "get list of sensor from commonSense" do

      stub_request(:get, "http://api.dev.sense-os.local/sensors.json?page=0&per_page=1000").
        with(:headers => {'Content-Type'=>'application/json', 'X-Session-Id'=>'1234'}).
        to_return(:status => 200, :body => response_list_sensors.to_json, :headers => {
          'Content-Type'=>'application/json'
        })

      logged_in_client.sensors.all.should_not be_empty

      logged_in_client.sensors.count.should == 3


      i = 0
      logged_in_client.sensors.each do |sensor|
        compare_to_sensor_info(sensor, response_list_sensors[:sensors][i])
        i += 1;
      end
    end

    xit "get first sensor data" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!
      sensor = @client.sensors.first

      sensor.should_not be nil
      compare_to_sensor_info(sensor)
    end

    xit "get sensor data by id" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!

      first = @client.sensors.first

      sensor = @client.sensors.find(first.id)
      sensor.should_not be_nil
    end


    xit "filter sensor data" do
      sensor = @client.sensors.build(sensor_info)
      sensor.save!
      sensors = @client.sensors.where(page: 0, per_page: 1, owned: true , details: "full")
      sensors.to_a.should_not be_empty
    end

    xit "should handle pagination" do
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
