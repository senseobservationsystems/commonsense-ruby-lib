module CS
  module EndPoint
    class Sensor
      include EndPoint

      attribute :name, :display_name, :device_type, :pager_type, :data_type, :data_structure
      resources :sensors
      resource :sensor

      def initialize(hash={})
        from_hash(hash)
        if self.data_type == "json"
          if self.data_structure && self.data_structure.kind_of?(String)
            self.data_structure = JSON.parse(self.data_structure) rescue nil
          end
        end
      end

      # overide Endpoint#to_parameters
      def to_parameters
        param = self.to_h(false)
        if param[:data_type] == "json"
          if param[:data_structure] && !param[:data_structure].kind_of?(String)
            param[:data_structure] = param[:data_structure].to_json
          end
        end

        {sensor: param}
      end

      def data
        Relation::SensorDataRelation.new(self.id, self.session)
      end
    end
  end
end
