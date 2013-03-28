module CommonSense
  class SensorDataRelation
    attr_reader :session
    attr_accessor :page, :per_page, :start_date, :end_date, :date, :last, :sort, :interval
    
    include Enumerable

    def initialize(session=nil)
      @session = session
      page = 0
      per_page = 1000
    end

    def build(attributes={})
      data = CommonSense::SensorData.new
      data.session = self.session
      data
    end
  end
end
