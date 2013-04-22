module CommonSense
  module Relation
    class SensorRelation
      include Relation

      parameter :page, Integer, default: 0, required: true
      parameter :per_page, Integer, default: 1000, required: true, maximum: 1000
      parameter :shared, Boolean
      parameter :owned, Boolean
      parameter :physical, Boolean
      parameter :details, String, valid_values: ["no", "full"]

      def initialize(session=nil)
        @session = session
        page = 0
        per_page = 1000
      end

      def get_url
        "/sensors.json"
      end

      def each(&block)
        page = self.page || 0;
        begin
          sensors = get_data({
            page: page, per_page: self.per_page, shared: self.shared,
            owned: self.owned, physical: self.physical, details: self.details
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

      def build(attribtues={})
        sensor = EndPoint::Sensor.new(attribtues)
        sensor.session = self.session
        sensor
      end

      def find(id)
        check_session!
        sensor = EndPoint::Sensor.new(id: id)
        sensor.session = self.session
        sensor.retrieve ? sensor : nil
      end

      private
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
