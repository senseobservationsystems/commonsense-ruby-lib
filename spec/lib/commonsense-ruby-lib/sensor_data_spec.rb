require 'spec_helper'

module CommonSense
  describe SensorData do

    let!(:value) do
      {"x-axis" => 1.0, "y-axis" => 2.0, "z-axis" => 3.0}
    end

    let!(:now) do
      Time.now.to_f
    end

    describe "Initiating new data point" do
      it "shoudl assign the data point property on initialize" do
        data = SensorData.new(sensor_id: 1, date: now, value: value)

        data.sensor_id.should eq(1)
        data.date.should eq(now)
        data.value.should eq(value)
      end
    end

    describe "Creating" do
      it "should create a new data point" do
        data = SensorData.new(sensor_id: 1, date: now, value: value)

        session = double("CommonSense::Session")
        session.should_receive(:post).with("/sensors/1/data.json", {data: [{date: now, value: value.to_json}]})
        session.stub(:response_headers => {"location" => "http://foo.bar/sensors/1/data/1"})
        session.stub(:response_code => 201)
        data.session = session

        data.create!.should be_true
      end
    end

    describe "Get specific data point" do
      it "shoudl request data point from commonSense" do
        data = SensorData.new
        data.sensor_id = 1
        data.id = "735f38333334645f31333533363536373737313233"

        session = double("CommonSense::Session")
        retval = {
          "data" => [{
            "date" => "1353656777.123",
            "value" => "10",
            "id" => "735f38333334645f31333533363536373737313233"
          }]
        }
        session.should_receive(:get).with("/sensors/1/data/#{data.id}.json").and_return(retval)
        session.stub(:response_code => 200)
        data.session = session

        data.retrieve!.should be_true

      end
    end

    describe "Update specific data point" do

    end

    describe "Delete specific data point" do

    end

    describe "Get list data point per sensor" do

    end

  end
end
