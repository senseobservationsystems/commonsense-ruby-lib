require 'spec_helper'

module CS
  module Collection
    describe SensorDataCollection do
      describe "process_batch" do
        it "should convert into multi data payload" do
          sdc = SensorDataCollection.new
          sdc.batch_size = 2

          current_batch = [
            EndPoint::SensorData.new(sensor_id: 1, value: 1),
            EndPoint::SensorData.new(sensor_id: 1, value: 2),
            EndPoint::SensorData.new(sensor_id: 2, value: 1),
            EndPoint::SensorData.new(sensor_id: 2, value: 2),
            EndPoint::SensorData.new(sensor_id: 1, value: 3),
            EndPoint::SensorData.new(sensor_id: 1, value: 4),
            EndPoint::SensorData.new(sensor_id: 2, value: 3),
            EndPoint::SensorData.new(sensor_id: 2, value: 4)
          ]

          sdc.process_batch(current_batch)
        end
      end
    end
  end
end
