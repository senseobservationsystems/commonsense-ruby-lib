module CommonSense
  class Session
    def initialize(commonsense_uri="http://api.sense-os.nl")
      @base_uri = commonsense_uri
      @auth_proxy = nil
    end

    # login to commonsense 
    # @return [String] session_id 
    def login(username, password)
      @auth_proxy = CommonSense::Auth::HTTP.new(@base_uri)
      @auth_proxy.login(username, password)
    end

    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @auth_proxy = CommonSense::Auth::OAuth.new(consumer_key, consumer_secret, 
                                                 access_token, access_token_secret,
                                                 @base_uri)
    end

    def session_id
      auth_proxy.session_id
    end

    def session_id=(session_id)
      auth_proxy = CommonSense::Auth::HTTP.new
      auth_proxy.session_id = session_id
    end

    def auth_proxy
      raise 'The session is not logged in' unless @auth_proxy
      @auth_proxy
    end

    def get(path, headers = {})
      auth_proxy.get(path, headers)
    end

    def post(path, body = '', headers = {})
      auth_proxy.post(path, body, headers = {})
    end

    def put(path, body = '', headers = {})
      auth_proxy.put(path, body, headers)
    end

    def delete(path, headers = {})
      auth_proxy.delete(path, body, headers)
    end

    def head(path, headers = {})
      auth_proxy.head(path, headers)
    end

    def response_code 
      auth_proxy.response_code
    end

    def response_body
      auth_proxy.response_body
    end
    
    def errors
      auth_proxy.errors
    end

    def base_uri=(uri = nil)
      auth_proxy.base_uri = uri
    end
  end
end
