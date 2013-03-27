require 'commonsense-ruby-lib/serializer'
require 'pry'

module CommonSense
  module EndPoint
    include CommonSense::Serializer

    attr_accessor :session

    def initialize(hash={})
      from_hash(hash)
    end

    def to_parameters
      resource.nil? ? self.to_h(false) : { self.resource => self.to_h(false) }
    end

    def save!
      check_session!

      if @id
        self.update!
      else
        self.create!
      end
    end

    def save
      save! rescue nil
    end

    def create!
      parameter = self.to_parameters
      res = session.post(post_url, parameter)

      if session.response_code != 201
        errors = session.errors rescue nil
        raise CommonSense::ResponseError, errors
      end

      location_header = session.response_headers["location"]
      id = location_header.scan(/.*\/#{resources}\/(.*)/)[0] if location_header
      self.id = id[0] if id

      self
    end

    def create
      create!
    rescue
      nil
    end

    def retrieve!
      check_session!
      raise CommonSense::ResourceIdError unless @id

      res = session.get(get_url)

      from_hash(res[resource.to_s])

      self
    end

    def reload!
      retieve!
    end

    def retrieve
      retrieve! rescue nil
    end

    def reload
      retrieve
    end

    def update!
      check_session!
      raise CommonSense::ResourceIdError unless @id

      parameter = self.to_parameters
      res = session.put(put_url, parameter)

      self
    end

    def update
      update! rescue nil
    end

    def delete!
      check_session!
      raise CommonSense::ResourceIdError unless @id

      res = session.delete(delete_url)
      self.id = nil

      self
    end

    def delete
      delete! rescue nil
    end

    def url_for(method, id=nil)
      raise CommonSense::ResourcesError if resources.nil?
      url = self.class.class_variable_get("@@#{method}_url".to_sym)
      url = url.sub(":id", "#{@id}") if id
      url
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
    end

    def resources
      self.class.class_variable_get(:@@resources)
    end

    private
    def check_session!
      raise CommonSense::SessionEmptyError unless @session
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
