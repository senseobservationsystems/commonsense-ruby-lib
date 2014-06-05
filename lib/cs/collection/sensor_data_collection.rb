require 'delegate'

module CS
  module Collection
    class SensorDataCollection < SimpleDelegator
      attr_accessor :session
      attr_accessor :batch_size

      def initialize
        @batch_size = 1000
        super([])
      end

      def save!
        check_session!

        # group batch
        self.each_slice(@batch_size) do |batch|
          body = process_batch(batch)
          @session.post(get_url, body)
        end
      end

      ##
      # Given array of sensor data it will group the data by sensor_id
      # and construct payload for multiple sensor upload
      def process_batch(batch)
        sensors = {}
        batch.each do |point|
          next if point.nil? || point.sensor_id.nil?
          sensor_id = point.sensor_id

          if !sensors[sensor_id]
            sensors[sensor_id] = {
              sensor_id: sensor_id,
              data: []
            }
          end

          sensors[sensor_id][:data].push(point.to_cs_point)
        end

        retval = []
        sensors.each do |k, v|
          retval.push(v)
        end

        {sensors: retval}
      end

      def get_url
        "/sensors/data.json"
      end

      private
      def check_session!
        raise Error::SessionEmptyError unless @session
      end
    end
  end
end
