module CommonSense
  module Relation

    # Class that used to query List of sensor data from CS.
    #
    # == parameters
    # The relation object has serveral parameter
    #
    # * page     : Integer, number of page in pagination. starts from 0
    # * per_page : Integer, number of sensor per page, default 1000, max: 1000
    # * shared   : Boolean, filter only sensor that is shared.
    # * onwed    : Boolean, filter only sensor that user own.
    # * physical : Boolean, filter only physical sensor (sensor that connected to device).
    # * details  : String "no" or "full", gives full description of sensor
    #
    # == Examples
    # This is an example how would you use the sensors relation object
    #
    # === Create Sensors Relation
    #
    #    client = CommonSense::Client.new
    #    client.login('user', 'password')
    #    session = client.session
    #
    #    # create sensors relation
    #    sensors = client.sensors
    #
    #    # is the same as
    #    sensors = CommonSense::Relation::Sensors.new
    #    sensors.session = session
    #
    # === Get all sensor
    #
    #    sensors = client.sensors
    #    sensors.to_a
    #
    # === Get sensor by specifying parameters
    #
    #    client.sensors.where(page: 0, per_page: 1000)
    #    client.sensors.where(owned: true)
    #    client.sensors.where(physical: true)
    #    client.sensors.where(page: 0, per_page: 1000, physical: true, owned: true, details: "full")
    #
    # === Chain parameters
    #
    #    client.sensors.where(page:0, per_page: 10).where(physical: true)
    #
    # === Find sensor by name
    #
    #    client.sensors.find_by_name(/position/)
    #    client.sensors.find_by_name(/position/, owned: true) # or
    #    client.sensors.where(owned: true).find_by_name(/position/)
    #
    # === Get first sensor or last sensor
    #
    #     sensor = client.sensors.first
    #     sensor = client.sensors.last
    #
    # === Get number of sensors
    #
    #     client.sensors.count
    #     client.sensors.where(owned: true).count
    class SensorRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :shared, Boolean
      parameter :owned, Boolean
      parameter :physical, Boolean
      parameter :details, String, valid_values: ["no", "full"]
      parameter :group_id, String

      def initialize(session=nil)
        @session = session
        page = 0
        per_page = 1000
      end

      # Create a new {EndPoint::Sensor Sensor} object.
      #
      # example:
      #
      #    sensor = client.sensors.build
      def build(attribtues={})
        sensor = EndPoint::Sensor.new(attribtues)
        sensor.session = self.session
        sensor
      end

      # Find {EndPoint::Sensor Sensor} by id
      #
      # example:
      #
      #    sensor = client.sensors.find("1")
      def find(id)
        check_session!
        sensor = EndPoint::Sensor.new(id: id)
        sensor.session = self.session
        sensor.retrieve ? sensor : nil
      end

      # Find sensor by name in regular expression.
      # The second argument is parameter that is usualy us in {#where where}
      #
      # example:
      #
      #    client.sensors.find_by_name(/position/, owned: true)
      def find_by_name(regex, parameters={})
        check_session!
        self.where(parameters)
        self.select { |sensor| sensor.name =~ regex }
      end

      def each(&block)
        page = self.page || 0;
        begin
          sensors = get_data!({
            page: page, per_page: self.per_page, shared: self.shared,
            owned: self.owned, physical: self.physical, details: self.details, group_id: self.group_id
          })

          sensors = sensors["sensors"]
          if !sensors.empty?
            sensors.each do |sensor|
              sensor = EndPoint::Sensor.new(sensor)
              sensor.session = session
              yield sensor
            end

            page += 1
          end

        end while sensors.size == self.per_page
      end

      private
      def get_url
        "/sensors.json"
      end

      def parse_single_resource(sensors)
        sensors = sensors["sensors"]
        if !sensors.empty?
          sensor = EndPoint::Sensor.new(sensors[0])
          sensor.session = self.session

          return sensor
        end
      end

      def get_single_resource(params={})
        options = {
          page: 0, per_page: 1, shared: self.shared,
          owned: self.owned, physical: self.physical, details: self.details
        }
        options.merge!(params)
        get_data(options)
      end
    end
  end
end
