require "commonsense-ruby-lib/version"
require "commonsense-ruby-lib/error"
require "commonsense-ruby-lib/auth/http"
require "commonsense-ruby-lib/auth/oauth"
require "commonsense-ruby-lib/session"
require "commonsense-ruby-lib/end_point"
require "commonsense-ruby-lib/user"
require "commonsense-ruby-lib/group"
require "commonsense-ruby-lib/sensor"
require "commonsense-ruby-lib/sensor_data"
require "commonsense-ruby-lib/relation"
require "commonsense-ruby-lib/relations/sensor_relation"
require "commonsense-ruby-lib/relations/sensor_data_relation"

module CommonSense
  class Client
    attr_accessor :session, :base_uri

    def initialize(opts={})
      options = {
        base_uri: 'https://api.sense-os.nl',
      }.merge(opts)
      @base_uri = options[:base_uri]
    end

    def login!(user, password)
      @session = Session.new(base_uri: @base_uri)
      @session.login(user, password)
    end

    def login(user, password)
      login!(user, password) rescue nil
    end

    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @session = Session.new(base_uri: @base_uri)
      @session.oauth(consumer_key, consumer_secret, access_token, access_token_secret)
    end

    def set_session_id(session_id)
      @session = Session.new(base_uri: @base_uri)
      @session.session_id = session_id
    end

    def current_user
      user = User.new
      user.session = @session
      user.current_user
    end

    def new_user(hash={})
     user = User.new(hash)
     user.session = Session.new(base_uri: @base_uri, authentication: false)
     user
    end

    def sensors
      CommonSense::SensorRelation.new(@session)
    end

    def current_groups
      group = Group.new
      group.session = @session
      group.current_groups
    end

    def errors
      return @session.errors if @session
    end
  end
end

