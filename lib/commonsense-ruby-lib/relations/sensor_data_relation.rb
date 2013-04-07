module CommonSense
  class SensorDataRelation
    include Relation

    attr_accessor :sensor_id
    parameter :page, Integer, default: 0
    parameter :per_page, Integer, default: 1000, maximum: 1000
    parameter :start_date, Time
    parameter :end_date, Time
    parameter :date, Time
    parameter :last, Boolean
    parameter :sort, String, valid_values: ["ASC", "DESC"]
    parameter :interval, Integer, valid_values: [604800, 86400, 3600, 1800, 600, 300, 60]
    parameter :sensor_id, String

    include Enumerable

    def initialize(sensor_id, session=nil)
      self.sensor_id = sensor_id
      self.session = session
      page = 0
      per_page = 1000
    end

    def get_url
      "/sensors/#{self.sensor_id}/data.json"
    end

    def build(attributes={})
      data = CommonSense::SensorData.new
      data.sensor_id = self.sensor_id
      data.session = self.session
      data
    end
  end
end
