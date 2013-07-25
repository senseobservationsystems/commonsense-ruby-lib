require 'cs/serializer'
module CS
  module EndPoint
    include CS::Serializer

    attr_accessor :session

    def initialize(hash={})
      from_hash(hash)
    end

    # generate a hash representation of this end point
    def to_parameters
      r = self.resource rescue nil
      r.nil? ? self.to_h(false) : { self.resource => self.to_h(false) }
    end

    def inspect
      inspection = self.to_h.collect {|k,v| "#{k}: #{v.inspect}"}.compact.join(", ")
      "#<#{self.class} #{inspection}>"
    end

    # get value of property name
    def parameter(name)
      self.instance_variable_get("@#{name}")
    end

    # Persist end point object to CS. It will create a new record on CS
    # if it's a new object or it will update the object. It will throw an exception
    # if it could not persist object to CS
    #
    # example for {Sensor} object:
    #
    #     sensor = client.sensors.build
    #     sensor.name = "accelerometer"
    #     sensor.display_name = "Accelerometer"
    #     sensor.device_type = "BMA123"
    #     sensor.pager_type = "email"
    #     sensor.data_type = "json"
    #     sensor.data_structure = {"x-axis" => "Float", "y-axis" => "Float", "z-axis" => "Float"}
    #
    #     sensor.save! # this will create new sensor on CS
    #     sensor.id # should give you the id of the sensor
    #
    #     sensor.name = "accelerometer edit"
    #     sensor.save! # this will update the sensor
    def save!
      check_session!

      if @id
        self.update!
      else
        self.create!
      end
    end

    # it will persist data to CS just like {#save!} but it will return false instead of exception
    # if it encouter error while persiting data
    def save
      save! rescue false
    end

    # Create a new end point object to CS. It will raise an exception if there is an error
    #
    # example for {Sensor} object:
    #
    #     sensor = client.sensors.build
    #     sensor.name = "accelerometer"
    #     sensor.display_name = "Accelerometer"
    #     sensor.device_type = "BMA123"
    #     sensor.pager_type = "email"
    #     sensor.data_type = "json"
    #     sensor.data_structure = {"x-axis" => "Float", "y-axis" => "Float", "z-axis" => "Float"}
    #
    #     sensor.create! # this will create new sensor on CS
    #     sensor.id # should give you the id of the sensor
    def create!
      parameter = self.to_parameters
      res = session.post(post_url, parameter)

      if session.response_code != 201
        errors = session.errors rescue nil
        raise Error::ResponseError, errors
      end

      location_header = session.response_headers["location"]
      id = scan_header_for_id(location_header)
      self.id = id[0] if id

      true
    end

    # Create a new endpoint object to CS, just like {#create!} but it will return false
    # if there is an error.
    def create
      create! rescue false
    end

    # Retrieve Data from CS of the current object based on the id of the object.
    # It will return an exception if there is an error
    #
    # example for {Sensor} object:
    #
    #     sensor = client.sensors.build
    #     sensor.id = "1"
    #     sensor.retrieve!
    def retrieve!
      check_session!
      raise Error::ResourceIdError unless @id

      res = session.get(get_url)
      if session.response_code != 200
        errors = session.errors rescue nil
        raise Error::ResponseError, errors
      end

      from_hash(res[resource.to_s]) if res
      true
    end

    # alias for {#retrieve!}
    def reload!
      retieve!
    end

    # it will retrieve / reload current object form CS, just like {#retrieve!} but it
    # will return false instead of raise an exception if there is an error.
    def retrieve
      retrieve! rescue false
    end

    # alias for {#retrieve}
    def reload
      retrieve
    end

    # Update current end point object to CS. It will throw an exception if there is an error
    #
    # example for {Sensor} object:
    #
    #     sensor = client.sensors.find(1)
    #     sensor.name = "new name"
    #     sensor.update!
    def update!
      check_session!
      raise Error::ResourceIdError unless @id

      parameter = self.to_parameters
      res = session.put(put_url, parameter)

      if session.response_code != 200
        errors = session.errors rescue nil
        raise Error::ResponseError, errors
      end

      true
    end

    # Update current end point object to CS, just like {#update!} but it will return nil
    # if there is an error
    def update
      update! rescue false
    end


    # Delete the current end point object from CS. It will throw an exception if there is an error
    #
    # example for {Sensor} object:
    #
    #     sensor = client.sensors.find(1)
    #     sensor.name = "new name"
    #     sensor.delete!
    def delete!
      check_session!
      raise Error::ResourceIdError unless @id

      res = session.delete(delete_url)

      if session.response_code != 200
        errors = session.errors rescue nil
        raise Error::ResponseError, errors
      end

      self.id = nil

      true
    end

    # Delete the current end point object from CS, just like {#delete!} but it will return nil
    # if there is an error
    def delete
      delete! rescue false
    end

    # return the commonsense URL for method
    # vaild value for method is `:get`, `:post`, `:put`, or `:delete`
    def url_for(method, id=nil)
      raise Error::ResourcesError if resources.nil?
      url = self.class.class_variable_get("@@#{method}_url".to_sym)
      url = url.sub(":id", "#{@id}") if id
      url
    end

    def duplicate
      clone = self.dup
      clone.id = nil
      clone
    end

    protected
    def scan_header_for_id(location_header)
      location_header.scan(/.*\/#{resources}\/(.*)/)[0] if location_header
    end

    def post_url
      url_for(:post)
    end

    def get_url
      url_for(:get, self.id)
    end

    def put_url
      url_for(:put, self.id)
    end

    def delete_url
      url_for(:delete, self.id)
    end

    def self.included(base)
      base.extend(ClassMethod)
    end

    def resource
      self.class.class_variable_get(:@@resource)
    rescue
      raise Error::ResourceError, "'resource' is not set up for class : #{self.class}"
    end

    def resources
      self.class.class_variable_get(:@@resources)
    end

    private
    def check_session!
      raise Error::SessionEmptyError unless @session
    end

    module ClassMethod
      def attribute(*args)
        attr_accessor *args

        unless @attribute_set
          @attribute_set = Set.new([:id])
          attr_accessor :id
        end
        @attribute_set.merge(args)
      end

      def attribute_set
        @attribute_set
      end

      def resources(resources)
        class_variable_set(:@@resources, resources)
        class_variable_set(:@@post_url, "/#{resources}.json")
        class_variable_set(:@@get_url, "/#{resources}/:id.json")
        class_variable_set(:@@put_url, "/#{resources}/:id.json")
        class_variable_set(:@@delete_url, "/#{resources}/:id.json")
      end

      def resource(resource)
        class_variable_set(:@@resource, resource)
      end
    end
  end
end
