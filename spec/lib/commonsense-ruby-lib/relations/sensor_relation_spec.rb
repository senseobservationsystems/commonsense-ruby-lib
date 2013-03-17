require 'spec_helper'
require 'commonsense-ruby-lib/sensor'

describe CommonSense::SensorRelation do

  describe "build" do
    it "should return a sensor object" do
      CommonSense::SensorRelation.build.should be_a_kind_of(CommonSense::Sensor)
    end
  end
  
end
