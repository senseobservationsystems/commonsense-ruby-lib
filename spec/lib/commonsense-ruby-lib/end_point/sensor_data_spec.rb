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
        expect { data.retrieve!.should }.to raise_error(NotImplementedError)
      end
    end

    describe "Update specific data point" do
      it "shoudl request data point from commonSense" do
        data = SensorData.new
        expect { data.retrieve!.should }.to raise_error(NotImplementedError)
      end
    end

    describe "Delete specific data point" do
      it "should perform DELETE request to commonSense" do
        data = SensorData.new(sensor_id: 1, id: "abcdef")

        session = double("CommonSense::Session")
        session.should_receive(:delete).with("/sensors/1/data/abcdef.json")
        session.stub(:response_code => 200)
        data.session = session

        data.delete!.should be_true
      end
    end

  end
end
