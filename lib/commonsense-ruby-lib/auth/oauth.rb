require "oauth"

module CommonSense
  module Auth
    class OAuth

      attr_accessor :response_body, :response_code, :errors, :consumer_key,
        :consumer_secret, :access_token, :access_token_secret

      def initialize(consumer_key, consumer_secret, access_token, access_token_secret, uri=nil)
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        @access_token = access_token
        @access_token_secret = access_token_secret
        oauth_base = ::OAuth::Consumer.new(consumer_key, consumer_secret, :site => uri)
        @oauth = ::OAuth::AccessToken.new(oauth_base, access_token, access_token_secret)  
        reset
      end

      def oauth
        @oauth
      end

      def get(path, headers = {})
        reset
        response = oauth.get(path, headers)
        parse(response)
        @response_body
      end

      def post(path, body = '', headers = {})
        reset
        response = self.class.post(path, body, headers)
        @response_code = @response_body.response.code.to_i
        @response_body
      end

      def put(path, body = '', headers = {})
        reset
        @response_body = self.class.put(*args, &block)
        @response_code = @response_body.response.code.to_i
        @response_body
      end

      def delete(path, headers = {})
        reset
        @response_body = self.class.delete(*args, &block)
        @response_code = @response_body.response.code.to_i
        @response_body
      end

      def head(path, headers = {})
        reset
        @response_body = self.class.head(*args, &block)
        @response_code = @response_body.response.code.to_i
        @response_body
      end

      def base_uri=(uri = nil)
        self.class.base_uri uri
      end

      # login to commonsense 
      # @return [String] session_id 
      def login(username, password)
        password = Digest::MD5.hexdigest password
        post('/login.json', :query => {:username => username, :password => password})

        if @response_code == 200
          self.session_id = response_body['session_id']
        else
          errors = [response_body['error']]
        end

        session_id
      end

      private
      def reset
        @errors = nil
        @response_code = nil
        @response_body = nil
      end

      # convert the body to hash if response is "application/json"
      def parse(response)
        @response_body = response.content_type == "application/json" ? JSON(response.body) : response.body
        @response_code = response.code.to_i
      end
    end
  end
end
