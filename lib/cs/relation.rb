module CS
  module Relation
    module Boolean; end

    def check_session!
      raise Error::SessionEmptyError unless @session
    end

    def get_url
      raise Error::NotImplementedError, "the class #{self.class} does not respond to 'get_url' "
    end

    def get_data!(params={})
      check_session!
      options = get_options(params)
      session.get(get_url, options)
    end

    def limit(num)
      @limit = num
      return self
    end

    def parameter(name)
      self.instance_variable_get("@#{name}")
    end

    def get_options(input={})
      options = {}

      self.class.parameters.each do |parameter, param_option|
        value = self.parameter(parameter)
        value = input[parameter] if input.has_key?(parameter)

        value = process_param_integer(parameter, value, param_option) if param_option[:type] == Integer
        value = process_param_boolean(parameter, value, param_option) if param_option[:type] == Boolean
        value = process_param_string(parameter, value, param_option) if param_option[:type] == String

        if value.kind_of?(Time)
          value = value.to_f
        end

        options[parameter] = value if value
      end

      options
    end

    def get_data(params={})
      get_data!(params) rescue nil
    end

    def all
      self.to_a
    end

    def count
      check_session!
      resource = get_single_resource
      resource["total"] if resource
    end

    def find_or_new(attribute)
      check_session!

      self.each do |resource|
        found = true
        attribute.each do |key, value|
          if resource.parameter(key) != value
            found = false
            break
          end
        end

        return resource if found
      end

      resource = resource_class.new(attribute)
      resource.session = self.session
      resource
    end

    def find_or_create!(attribute)
      resource = find_or_new(attribute)
      resource.save! if resource.id.nil?
      resource
    end

    def find_or_create(attribute)
      find_or_create!(attribute) rescue nil
    end

    def first
      resource = get_single_resource
      parse_single_resource(resource)
    end

    def last
      total = count
      resource = get_single_resource(page: count - 1)
      parse_single_resource(resource)
    end

    def inspect
      inspection = self.class.parameters.collect {|k,v| "#{k}: #{parameter(k).inspect}"}.compact.join(", ")
      "#<#{self.class} #{inspection}>"
    end

    def where(params={})
      process_alias!(params)
      params.keep_if {|k| self.class.parameters[k]}

      params.each do |k,v|
        param_option = self.class.parameters[k]

        value = process_param_integer(k, v, param_option) if param_option[:type] == Integer
        value = process_param_boolean(k, v, param_option) if param_option[:type] == Boolean
        value = process_param_string(k, v, param_option) if param_option[:type] == String
        value = process_param_time(k, v, param_option) if param_option[:type] == Time

        self.send("#{k}=", value)
      end

      self
    end

    module ClassMethod
      def parameter(name, type, *args)
        attr_accessor name
        self.parameters ||= {}

        param = {type: type}
        param.merge!(args[0]) unless args.empty?

        self.class_eval %{
          def #{name}
            if @#{name}.nil? && (default = self.class.parameters[:#{name}][:default])
              @#{name} = default
            end

            @#{name}
          end
        }

        self.parameters[name] = param
      end

      def parameter_alias(name, name_alias)
        attr_accessor name
        self.parameters_alias ||= {}
        self.parameters_alias[name] = name_alias
      end

      def parameters_alias=(parameters_alias)
        @parameters_alias = parameters_alias
      end

      def parameters_alias
        @parameters_alias
      end

      def parameters=(parameters)
        @parameters = parameters
      end

      def parameters
        @parameters
      end
    end

    protected
    def self.included(base)
      base.send(:include, Enumerable)
      base.extend(ClassMethod)
      base.class_eval do
        attr_accessor :session
      end
    end

    def resource_class
      raise Error::NotImplementedError, "resource_class is not implemented for class : #{self.class}"
    end

    def parse_single_resource(resource)
      raise Error::NotImplementedError, "parse_single_resource is not implemented for class : #{self.class}"
    end

    def get_single_resource(params={})
      raise Error::NotImplementedError, "get_single_resource is not implemented for class : #{self.class}"
    end

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

      if !value.nil? && !value.kind_of?(Time)
        if value.kind_of?(Numeric)
          retval = Time.at(retval)
        else
          retval = value.to_time
        end
      end

      retval = process_default_value(name, retval, param_option)
      retval = process_valid_values(name, value, param_option) if param_option[:valid_values]

      retval
    end
  end
end
