require "commonsense-ruby-lib/version"
require "commonsense-ruby-lib/auth/http"
require "commonsense-ruby-lib/auth/oauth"
require "commonsense-ruby-lib/session"
require "commonsense-ruby-lib/end_point"
require "commonsense-ruby-lib/user"
require "commonsense-ruby-lib/group"

module CommonSense
  class Client
    attr_accessor :session

    def login(user, password)
      @session = Session.new
      @session.login(user, password)
    end

    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @session = Session.new
      @session.oauth(consumer_key, consumer_secret, access_token, access_token_secret)
    end

    def set_session_id(session_id)
      @session = Session.new
      @session.session_id = session_id
    end

    def current_user
      user = User.new
      user.session = @session
      user.current_user
    end

    def current_groups
      group = Group.new
      group.session = @session
      group.current_groups
    end
  end
end

