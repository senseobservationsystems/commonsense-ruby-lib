require 'commonsense-ruby-lib/relation'

module CommonSense
  class SensorRelation
    attr_reader :session
    attr_accessor :page, :per_page, :shared, :owned, :physical, :details
    include Enumerable

    def initialize(session=nil)
      @session = session
      page = 0
      per_page = 1000
    end

    def each(&block)
      page = self.page || 0;
      begin
        sensors = get_sensor({
          page: page, per_page: self.per_page, shared: self.shared,
          owned: self.owned, physical: self.physical, details: self.details
        })

        sensors = sensors["sensors"]
        if !sensors.empty?
          sensors.each do |sensor|
            sensor = CommonSense::Sensor.new(sensor)
            sensor.session = session
            yield sensor
          end

          page += 1
        end

      end while sensors.size == self.per_page
    end

    def build(attribtues={})
      sensor = CommonSense::Sensor.new(attribtues)
      sensor.session = self.session
      sensor
    end

    def check_session!
      raise CommonSense::SessionEmptyError unless @session
    end

    def count
      check_session!
        sensors = get_sensor_self
      sensors["total"] if sensors
    end

    def first
      sensors = get_sensor_self

      sensors = sensors["sensors"]
      if !sensors.empty?
        sensor = CommonSense::Sensor.new(sensors[0])
        sensor.session = self.session

        return sensor
      end
    end

    def get_sensor!(params={})
      check_session!

      options = {page: 0, per_page: 1000}
      options[:page] = params[:page] if params[:page].kind_of?(Fixnum)
      options[:per_page] = params[:per_page] if params[:per_page].kind_of?(Fixnum)
      options[:shared] = 1 if params[:shared]
      options[:owned] = 1 if params[:owned]
      options[:physical] = 1 if params[:physical]
      options[:details] = params[:details] if details_valid?(params[:details])

      session.get("/sensors.json", options)
    end

    def where(params={})
      # todo Fix optional parameter
      options = {page: 0, per_page: 1000}.merge(params)
      self.page = params[:page] if params[:page].kind_of?(Fixnum)
      self.per_page= params[:per_page] if params[:per_page].kind_of?(Fixnum)
      self.shared = 1 if params[:shared]
      self.owned = 1 if params[:owned]
      self.physical = 1 if params[:physical]
      self.details = params[:details] if details_valid?(params[:details])
      self
    end

    def get_sensor_self(params={})
      get_sensor({
        page: 0, per_page: 1, shared: self.shared,
        owned: self.owned, physical: self.physical, details: self.details
      })
    end

    def find(id)
      check_session!
      sensor = CommonSense::Sensor.new(id: id)
      sensor.session = self.session
      sensor.retrieve
    end

    def get_sensor(params={})
      get_sensor!(params) rescue nil
    end

    def all
      self.to_a
    end

    private
    def details_valid?(details)
      details and details.kind_of?(String) and
      ["no", "full"].include?(details.to_lower)
    end
  end
end
