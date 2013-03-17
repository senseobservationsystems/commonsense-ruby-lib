module CommonSense
  class Sensor
    include CommonSense::EndPoint

    attribute :name, :display_name, :device_type, :pager_type, :data_type, :data_structure
    resources :sensors
    resource :sensor

    # overide Endpoint#to_parameters
    alias_method :original_to_parameters, :to_parameters
    def to_parameters
      param = original_to_parameters
      if param[:data_type] == "json"
        if param[:data_structure] && !param[:data_structure].kind_of?(String)
          param[:data_structure] = param[:data_structure].to_json
        end
      end

      param
    end

  end
end
