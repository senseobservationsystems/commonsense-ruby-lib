module CS
  module ParameterProcessor
    def process_alias!(params)
      return if self.class.parameters_alias.nil?

      aliases = params.select { |param| self.class.parameters_alias.include?(param) }
      aliases.each do |alias_to, value|
        alias_for = self.class.parameters_alias[alias_to]
        params[alias_for] = value
        params.delete(alias_to)
      end
    end

    def process_valid_values(name, value, param_option)
      return value unless param_option[:valid_values]

      if param_option[:valid_values].include?(value)
        value
      elsif !value.nil?
        raise ArgumentError, "Invalid value for parameter '#{name}'"
      end
    end

    def process_default_value(name, value, param_option)
      value.nil? ? param_option[:default] : value
    end


    def process_param(name, value, param_option)
      retval = value

      # this should be refactored to it's own classes
      retval = process_param_integer(name, value, param_option) if param_option[:type] == Integer
      retval = process_param_boolean(name, value, param_option) if param_option[:type] == Boolean
      retval = process_param_string(name, value, param_option) if param_option[:type] == String
      retval = process_param_time(name, value, param_option) if param_option[:type] == Time
      retval
    end

    def process_param_integer(name, value, param_option)
      if value.kind_of?(Integer)
        retval = value
        retval = process_valid_values(name, value, param_option) if param_option[:valid_values]
        maximum = param_option[:maximum]
        retval = maximum if maximum && retval > maximum
      end

      retval = process_default_value(name, retval, param_option)

      if !value.nil?  && !value.kind_of?(Integer)
        raise ArgumentError, "Received non Integer value for parameter '#{name}'"
      end

      retval
    end

    def process_param_boolean(name, value, param_option)
      retval = nil

      if value.nil?
        retval = param_option[:default] ? param_option[:default] : nil
      elsif [0, "0", false, "false"].include?(value)
        retval = 0
      else
        retval = 1
      end

      retval
    end

    def process_param_string(name, value, param_option)
      retval = value
      retval = process_valid_values(name, value, param_option) if param_option[:valid_values]
      retval = process_default_value(name, retval, param_option)

      retval
    end

    # This method prosess assignment for properties with datatype Time.
    # There are 3 type that is valid for this properties:
    #
    # * **Time**
    # * **Numeric**. It will convert this to ruby {Time}
    # * **Obejct that respond to #to_time** and return ruby {Time}
    #
    def process_param_time(name, value, param_option)
      retval = value

      if !value.nil?
        retval =  CS::Time.new(value)
      end

      retval = process_default_value(name, retval, param_option)
      retval = process_valid_values(name, value, param_option) if param_option[:valid_values]

      retval
    end
  end
end
