require "commonsense-ruby-lib/version"
require "commonsense-ruby-lib/error"
require "commonsense-ruby-lib/auth/http"
require "commonsense-ruby-lib/auth/oauth"
require "commonsense-ruby-lib/session"
require "commonsense-ruby-lib/end_point"
require "commonsense-ruby-lib/end_point/user"
require "commonsense-ruby-lib/end_point/group"
require "commonsense-ruby-lib/end_point/sensor"
require "commonsense-ruby-lib/end_point/sensor_data"
require "commonsense-ruby-lib/relation"
require "commonsense-ruby-lib/relation/sensor_relation"
require "commonsense-ruby-lib/relation/sensor_data_relation"

module CommonSense

  # Main entry class of the library.
  #
  # The login functionality always comes in two pair. The Bang (!) method
  # will raise an exception when there is an error and the normal (without !)
  # will return nil when it fails.
  #
  # The response can be viewed by looking at the {CommonSense::Session}
  #
  #     client.session # will return the session object
  #
  # == Authentication with User And Password
  #
  #     client = CommonSense::Client.new
  #     client.login('username', 'password')
  #
  # == Authentication using OAuth
  #
  #     client = CommonSense::Client.new
  #     client.oauth('CONSUMER_KEY', 'CONSUMER_SECRET', 'ACCESS_TOKEN', 'ACCESS_TOKEN_SECRET')
  #
  # == Using different API server
  #
  #     client = CommonSense::Client.new(base_uri: 'https://api.dev.sense-os.nl')
  #     # or
  #     client.base_uri = 'https://api.dev.sense-os.nl'
  #
  class Client
    attr_accessor :session, :base_uri

    def initialize(opts={})
      options = {
        base_uri: 'https://api.sense-os.nl',
      }.merge(opts)
      @base_uri = options[:base_uri]
    end

    # Create a new session to CommonSense using username and plain text password
    # with `login!` it will throw exception if there is an error
    #
    #    client = CommonSense::Client.new
    #    client.login!('username', 'password')
    def login!(user, password)
      @session = Session.new(base_uri: @base_uri)
      @session.login(user, password)
    end

    # Create a new session to CommonSense using username and plain text password
    # with `login` it will return nil if it not successful
    #
    #    client = CommonSense::Client.new
    #    client.login('username', 'password')
    def login(user, password)
      login!(user, password) rescue nil
    end

    # Create a new session to CommonSense using OAuth credentials
    #
    #    client = CommonSense::Client.new
    #    client.login('username', 'password')
    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @session = Session.new(base_uri: @base_uri)
      @session.oauth(consumer_key, consumer_secret, access_token, access_token_secret)
    end

    # Create new session by manually specifiying `session_id` parameter
    #
    #     client = CommonSense::Client.new
    #     client.session_id('12345')
    def set_session_id(session_id)
      @session = Session.new(base_uri: @base_uri)
      @session.session_id = session_id
    end

    # Retrun logged in user
    def current_user
      user = EndPoint::User.new
      user.session = @session
      user.current_user
    end

    # Create a new user
    #
    #     client = CommonSense::Client.new
    #     client.new_user(username: 'Ahmy')
    #     client.email = 'ahmy@gmail.com'
    #     ...
    #     client.save!
    def new_user(hash={})
     user = EndPoint::User.new(hash)
     user.session = Session.new(base_uri: @base_uri, authentication: false)
     user
    end

    # @see Relation::SensorRelation
    def sensors
      Relation::SensorRelation.new(@session)
    end

    def current_groups
      group = EndPoint::Group.new
      group.session = @session
      group.current_groups
    end

    # return errors got from session
    def errors
      return @session.errors if @session
    end
  end
end

