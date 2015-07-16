module CS
  module EndPoint
    class Sensor
      include EndPoint

      attribute :name, :display_name, :device_type, :pager_type, :data_type, :data_structure
      resources "sensors"
      resource "sensor"

      def initialize(hash={})
        from_hash(hash)
        parse_data_structure
      end

      def retrieve!
        super
        parse_data_structure
        true
      end

      def parse_data_structure
        if self.data_type == "json"
          if self.data_structure && self.data_structure.kind_of?(String)
            self.data_structure = JSON.parse(self.data_structure) rescue nil
          end
        end
      end


      def to_cs_value
        param = self.to_h(false)
        if param[:data_type] == "json"
          if param[:data_structure] && !param[:data_structure].kind_of?(String)
            param[:data_structure] = param[:data_structure].to_json
          end
        end

        param
      end

      # overide Endpoint#to_parameters
      def to_parameters
        {sensor: to_cs_value}
      end

      def data
        Relation::SensorDataRelation.new(self.id, self.session)
      end

      # Copy data from other sensor
      #
      # example :
      #
      #   source = client.sensors.find(1234)
      #   destination = clint.sensors.find(2345)
      #
      #   destination.copy_data(source, start_date: 12345, end_date: 12350)
      #
      def copy_data(sensor, parameters={})
        source = sensor.data.where(parameters)

        collection = self.data.collection
        source.each do |point|
          collection.push self.data.build(date: point.date, value: point.value)
        end

        collection.save!
      end
    end
  end
end
