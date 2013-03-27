module CommonSense
  class SensorData
    include CommonSense::EndPoint

    attribute :date, :value, :sensor_id
    resource :data

    def to_parameters
      param = self.to_h(false)
      param.delete(:sensor_id)
      param[:value] = param[:value].to_json
      {data: [param]}
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
