module CommonSense
  class SensorDataRelation
    attr_reader :session
    attr_accessor :page, :per_page, :start_date, :end_date, :date, :last, :sort, :interval, :sensor_id

    include Enumerable

    def initialize(sensor_id, session=nil)
      @sensor_id = sensor_id
      @session = session
      page = 0
      per_page = 1000
    end

    def build(attributes={})
      data = CommonSense::SensorData.new
      data.sensor_id = self.sensor_id
      data.session = self.session
      data
    end
  end
end
