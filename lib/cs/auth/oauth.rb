require "oauth"

module CS
  module Auth
    class OAuth

      attr_accessor :request_body, :request_headers, :response_body, :response_code, :response_headers, :errors, :consumer_key,
        :consumer_secret, :access_token, :access_token_secret, :logger

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

      def execute(&block)
        reset
        response = yield
        parse_response(response)
        @response_body
      end

      def get(path, query={}, headers = {})
        execute do
          path += '?' + URI.encode_www_form(query) unless query.empty?
          @request_headers = default_headers.merge(headers)
          oauth.get(path, headers)
        end
      end

      def post(path, body = '', headers = {})
        execute do
          @request_headers = default_headers.merge(headers)
          @request_body = body.to_json
          oauth.post(path, @request_body, headers)
        end
      end

      def put(path, body = '', headers = {})
        execute do
          @request_headers = default_headers.merge(headers)
          @request_body = body.to_json
          oauth.put(path, @request_body, headers)
        end
      end

      def delete(path, query={}, headers = {})
        execute do
          path += '?' + URI.encode_www_form(query) unless query.empty?
          @request_headers = default_headers.merge(headers)
          oauth.delete(path, headers)
        end
      end

      def head(path, headers = {})
        execute do
          @request_headers = default_headers.merge(headers)
          oauth.head(path, headers)
        end
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
