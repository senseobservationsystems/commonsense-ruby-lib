module CS
  module EndPoint
    # This object represent a sensor data point
    # usage example:
    #
    #    client = CS::Client.new
    #    client.login('username', 'password')
    #
    #    # Find the first position sensor
    #    sensor = client.sensors.find_by_name(/position/).first
    #
    #    # save data point
    #    data = sensor.data.build
    #    data.date = Time.now
    #    data.value = {"lux": 1}
    #    data.save!
    #
    #    # more compact version
    #    sensor.data.build(date: Time.now, value: {"lux => 1}).save!
    #
    class SensorData
      include CS::EndPoint

      attr_accessor :month, :week, :year
      attribute :date, :value, :sensor_id
      resources "data"
      resource "data"

      def to_cs_value
        param = self.to_h(false)
        param.delete(:sensor_id)
        value = param[:value]
        if value
          param[:value] = value.to_json unless value.kind_of?(String) || value.kind_of?(Numeric)
        end

        param[:date] = CS::Time.new(date).to_f if param[:date]

        param
      end

      def to_parameters
        {data: [to_cs_value]}
      end

      def date_human
        Time.new(@date)
      end

      # there is no currently end point for geting data by id
      def retrieve!
        raise Error::NotImplementedError, "There is no current end point to get sensor data by id"
      end

      # there is no currently end point for updating data
      def update!
        raise Error::NotImplementedError, "There is no current end point to update sensor data by id"
      end

      def scan_header_for_id(location_header)
        location_header.scan(/.*\/sensors\/(.*)\/(.*)/)[1] if location_header
      end

      def post_url
        "/sensors/#{sensor_id}/data.json"
      end

      def get_url
        "/sensors/#{sensor_id}/data/#{id}.json"
      end

      def put_url
        "/sensors/#{sensor_id}/data/#{id}.json"
      end

      def delete_url
        "/sensors/#{sensor_id}/data/#{id}.json"
      end
    end
  end
end
