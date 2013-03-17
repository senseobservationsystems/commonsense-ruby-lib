module CommonSense
  class SensorRelation
    def initialize(session=nil)
      @session = session
    end

    def build(attribtues={})
      sensor = CommonSense::Sensor.new(attribtues)
      sensor.session = @session
      sensor
    end
  end
end
