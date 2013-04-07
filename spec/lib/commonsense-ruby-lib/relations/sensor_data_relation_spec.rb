require 'spec_helper'

module CommonSense
  describe SensorDataRelation do

    let(:relation) {
      relation = SensorDataRelation.new
      relation.stub("check_session!").and_return(true)
      relation.stub("get_data").and_return(sensors)
      relation
    }

    describe "build" do
      it "should return a sensorData object" do
        sensor_id = 1
        SensorDataRelation.new(sensor_id).build.should be_a_kind_of(SensorData)
      end
    end

    describe "get_data!" do
      it "should fetch the data point from commonSense" do
        sensor_id = 1
        session = double("Session")
        option = { page: 100, per_page: 99, start_date: 1365278885,
          end_date: 1365278886, last: 1, sort: 'ASC', interval: 300 }
        session.should_receive(:get).with("/sensors/#{sensor_id}/data.json", option)

        relation = SensorDataRelation.new(sensor_id, session)
        relation.get_data!(page:100, per_page: 99, start_date: 1365278885,
          end_date: 1365278886, last: true, sort: 'ASC', interval: 300)
      end
    end

    describe "get_data" do
       it "call get_data! and not throw exception" do

       end
    end

    describe "each" do
      it "should get all sensor data based on the criteria and yield" do

      end
    end

    describe "count" do
      it "should return the total number of sensor data match with criteria" do

      end
    end

    describe "first" do
      it "should return the first record" do

      end
    end

    describe "last" do
      it "should return the last record" do

      end
    end

    describe "where" do
      it "should update the query parameter" do

      end
    end

    describe "all" do
      it "return array of all matching sensor" do

      end
    end
  end
end
