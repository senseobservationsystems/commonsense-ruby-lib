require 'spec_helper'

module CommonSense
  describe SensorDataRelation do

    describe "build" do
      it "should return a sensorData object" do
        SensorDataRelation.new.build.should be_a_kind_of(SensorData)
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

    describe "get_data!" do
      it "should fetch the data from commonSense" do
        
      end
    end

    describe "get_data" do
       it "call get_data! and not throw exception" do
         
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
