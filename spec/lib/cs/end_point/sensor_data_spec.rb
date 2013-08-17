require 'spec_helper'

module CS
  module EndPoint
    describe SensorData do

      let!(:value) do
        {"x-axis" => 1.0, "y-axis" => 2.0, "z-axis" => 3.0}
      end

      let!(:now) do
        Time.now
      end

      context "Initiating new data point" do
        it "should assign the data point property on initialize" do
          data = SensorData.new(sensor_id: 1, date: now, value: value)

          data.sensor_id.should eq(1)
          data.date.to_i.should eq(now.to_i)
          data.value.should eq(value)
        end
      end

      describe "to_parameters" do
        context "given CS::Time object" do
          it "should convert date to epoch" do
            data = SensorData.new(id: 1)

            date = Time.now
            epoch = date.to_f

            data.date = date
            data.to_parameters[:data][0][:date].should be_within(0.001).of(epoch)
          end
        end

        context "given TimeLord object" do
          it "should convert date to epoch" do
            require 'time-lord'
            data = SensorData.new(id: 1)

            date = 1.hours.ago
            epoch = Time.new(date).to_f

            data.date = date
            data.to_parameters[:data][0][:date].should be_within(0.001).of(epoch)
          end
        end

        context "given method respond to_time" do
          it "should convert date to epoch" do
            data = SensorData.new(id: 1)

            date = Time.now
            epoch = date.to_f

            double = double()
            double.should_receive(:to_time).and_return(date)

            data.date = double
            data.to_parameters[:data][0][:date].should be_within(0.001).of(epoch)
          end
        end
      end

      context "Creating" do
        it "should create a new data point" do
          date_value = Time.now
          data = SensorData.new(sensor_id: 1, date: date_value, value: value)

          session = double("CS::Session")
          session.should_receive(:post).with("/sensors/1/data.json", {data: [{date: date_value.to_f.round(3), value: value.to_json}]})
          session.stub(:response_headers => {"location" => "http://foo.bar/sensors/1/data/1"})
          session.stub(:response_code => 201)
          data.session = session

          data.create!.should be_true
        end
      end

      context "Get specific data point" do
        it "should request data point from commonSense" do
          data = SensorData.new
          expect { data.retrieve!.should }.to raise_error(Error::NotImplementedError)
        end
      end

      context "Update specific data point" do
        it "should request data point from commonSense" do
          data = SensorData.new
          expect { data.retrieve!.should }.to raise_error(Error::NotImplementedError)
        end
      end

      context "Delete specific data point" do
        it "should perform DELETE request to commonSense" do
          data = SensorData.new(sensor_id: 1, id: "abcdef")

          session = double("CS::Session")
          session.should_receive(:delete).with("/sensors/1/data/abcdef.json")
          session.stub(:response_code => 200)
          data.session = session

          data.delete!.should be_true
        end
      end
    end
  end
end
