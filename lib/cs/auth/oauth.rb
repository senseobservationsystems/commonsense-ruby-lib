require "oauth"

module CS
  module Auth
    class OAuth

      attr_accessor :response_body, :response_code, :response_headers, :errors, :consumer_key,
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

      def get(path, query={}, headers = {})
        reset
        headers = default_headers.merge(headers)
        response = oauth.get(path, headers)
        parse_response(response)
        @response_body
      end

      def post(path, body = '', headers = {})
        reset
        headers = default_headers.merge(headers)
        response = oauth.post(path, body.to_json, headers)
        parse_response(response)

        @response_body
      end

      def put(path, body = '', headers = {})
        reset
        headers = default_headers.merge(headers)
        response = oauth.put(path, body.to_json, headers)
        parse_response(response)

        @response_body
      end

      def delete(path, query={}, headers = {})
        reset
        headers = default_headers.merge(headers)
        response = oauth.delete(path, headers)
        parse_response(response)

        @response_body
      end

      def head(path, headers = {})
        reset
        headers = default_headers.merge(headers)
        response = oauth.head(path, headers)
        parse_response(response)

        @response_body
      end

      def base_uri=(uri = nil)
        self.class.base_uri uri
      end


      private
      def default_headers
        {"Content-Type" => "application/json"}
      end

      def reset
        @errors = nil
        @response_code = nil
        @response_body = nil
      end

      # convert the body to hash if response is "application/json"
      def parse_response(response)
        @response_body = response.content_type == "application/json" ? (JSON(response.body) rescue nil) : response.body
        @response_code = response.code.to_i

        @response_headers = response.to_hash
        @response_headers.each do |k,v|
          @response_headers[k] = v[0] rescue nil
        end


        if @response_code >= 400
          @errors = [response_body['error']]
        end
      end
    end
  end
end
