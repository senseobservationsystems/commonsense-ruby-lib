require 'pry'
module CommonSense
  module Relation
    module Boolean; end

    def check_session!
      raise CommonSense::SessionEmptyError unless @session
    end

    def get_url
      raise CommonSense::NotImplementedError, "the class #{self.class} does not respond to 'get_url' "
    end

    def get_data!(params={})
      check_session!
      options = get_options(params)
      session.get(get_url, options)
    end

    def get_options(params)
      options = {}

      params.each do |k,v|
        param_option = self.class.parameters[k]

        value = v
        value = process_param_integer(v, param_option) if param_option[:type] == Integer
        value = process_param_boolean(v, param_option) if param_option[:type] == Boolean
        value = process_param_string(v, param_option) if param_option[:type] == String

        options[k] = value
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

    def first
      resource = get_single_resource

      parse_single_resource(resource)
    end

    def last
      total = count
      resource = get_single_resource(page: count - 1)

      parse_single_resource(resource)
    end

    def self.included(base)
      base.send(:include, Enumerable)
      base.extend(ClassMethod)
      base.class_eval do
        attr_accessor :session
      end
    end

    def where(params={})
      params.keep_if {|k| self.class.parameters[k]}

      params.each do |k,v|
        param_option = self.class.parameters[k]

        value = process_param_integer(v, param_option) if param_option[:type] == Integer
        value = process_param_boolean(v, param_option) if param_option[:type] == Boolean
        value = process_param_string(v, param_option) if param_option[:type] == String

        self.send("#{k}=", value)
      end

      self
    end

    module ClassMethod
      def parameter(name, type, *args)
        attr_accessor name
        self.parameters ||= {}

        param = {type: type}
        unless args.empty?
          param.merge!(args[0])
        end

        self.parameters[name] = param
      end

      def parameters=(parameters)
        @parameters = parameters
      end

      def parameters
        @parameters
      end
    end

    protected
    def parse_single_resource(resource)
      raise CommonSense::NotImplementedError, "parse_single_resource is not implemented for class : #{self.class}"
    end

    def get_single_resource(params={})
      raise CommonSense::NotImplementedError, "get_single_resource is not implemented for class : #{self.class}"
    end

    def process_valid_values(value, param_option)
      value if param_option[:valid_values].include?(value)
    end

    def process_default_value(value, param_option)
      value.nil? ? param_option[:default] : value
    end

    def process_param_integer(value, param_option)
      if value.kind_of?(Integer)
        retval = value
        retval = process_valid_values(value, param_option) if param_option[:valid_values]
      else
        retval = nil
      end

      retval = process_default_value(retval, param_option)

      retval
    end

    def process_param_boolean(value, param_option)
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

    def process_param_string(value, param_option)
      retval = value
      retval = process_valid_values(value, param_option) if param_option[:valid_values]
      retval = process_default_value(retval, param_option)

      retval
    end
  end
end
