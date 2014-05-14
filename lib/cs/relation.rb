module CS
  module Boolean; end
  module Relation

    def check_session!
      raise Error::SessionEmptyError unless @session
    end

    def get_url
      raise Error::NotImplementedError, "the class #{self.class} does not respond to 'get_url' "
    end

    def initialize(session=nil)
      @session = session
    end

    # Create a new Endpoint object.
    #
    # example:
    #
    #    sensor = client.sensors.build
    def build(attributes={})
      resource = resource_class.new(attributes)
      resource.session = self.session
      resource
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

    def parameters
      self.class.parameters
    end

    def get_data(params={})
      get_data!(params)
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
      resource = get_single_resource(page: count - 1)
      parse_single_resource(resource)
    end

    def inspect
      entries = to_a.take(11).map!(&:inspect)
      entries[10] = '...' if entries.size == 11

      "#<#{self.class.name} [#{entries.join(", \n")}]>"
    end

    def get_options(input={})
      options = {}

      self.class.parameters.each do |name, param_option|
        value = self.parameter(name) # get value from object
        value = input[name] if input.has_key?(name) # override

        value = process_param(name, value, param_option)
        value = value.to_f if value.kind_of?(Time)

        options[name] = value if value
      end

      options
    end

    def where(params={})
      process_alias!(params)
      params.keep_if {|k| self.class.parameters[k]}

      params.each do |name,value|
        param_option = self.class.parameters[name]

        value = process_param(name, value, param_option)
        self.send("#{name}=", value)
      end

      self
    end

    def each_batch(params={}, &block)
      check_session!
      options = get_options(params)

      self.page ||= 0;

      begin
        options[:page] = self.page
        data = get_data(options)

        data = data[resource_class.resources_name] unless data.nil?
        if !data.nil? && !data.empty?
          yield data
          self.page += 1
        end
      end while data && data.size == self.per_page
    end

    def each(&block)
      counter = 0
      self.each_batch do |data|
        data.each do |data_point|
          resource = resource_class.new(data_point)
          resource.session = session
          yield resource
          counter += 1

          return if @limit && @limit == counter
        end
      end
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
      base.send(:include, ParameterProcessor)
      base.extend(ClassMethod)
      base.class_eval do
        attr_accessor :session
      end
    end

    def resource_class
      raise Error::NotImplementedError, "resource_class is not implemented for class : #{self.class}"
    end

    def parse_single_resource(data)
      resources = data[resource_class.resources_name]
      if !resources.empty?
        resource = resource_class.new(resources[0])
        resource.session = self.session

        return resource
      end
    end

    def get_single_resource(params={})
      options = get_options.merge!({ page: 0, per_page: 1 })
      options.merge!(params)
      get_data(options)
    end
  end
end
