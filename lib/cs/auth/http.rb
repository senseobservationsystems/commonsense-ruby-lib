require "httparty"
require "json"

module CS
  module Auth
    class HTTP
      include HTTParty

      attr_accessor :request_body, :request_headers, :response_body, :response_code, :response_headers, :errors, :logger, :base_uri
      attr_reader :session_id, :api_key

      def initialize(base_uri = nil, api_key = nil)
        @base_uri = base_uri
        @api_key = api_key
        @session_id = nil
        reset
      end

      def execute(&block)
        reset
        @response_body = yield
        parse_response
        @response_body
      end

      def process_api_key(path)
        return path if @api_key.nil?

        if URI(path).query.nil?
          path += "?API_KEY=#{@api_key}"
        else
          path += "&API_KEY=#{@api_key}"
        end

        path
      end

      def process_path(path)
        return base_uri + path
      end

      def get(path, query={}, headers = {})
        execute do
          @request_headers = default_headers.merge(headers)
          options = {query: query, headers: @request_headers}
          path = process_api_key(process_path(path))
          self.class.get(path, options)
        end
      end

      def post(path, body = '', headers = {})
        execute do
          self.class.post(process_path(path), prepare(body, headers))
        end
      end

      def put(path, body = '', headers = {})
        execute do
          self.class.put(process_path(path), prepare(body, headers))
        end
      end

      def delete(path, query={}, headers = {})
        execute do
          options = {query: query, headers: @request_headers}
          self.class.delete(process_path(path), options)
        end
      end

      def head(path, headers = {})
        execute do
          self.class.head(process_path(path), prepare(nil, headers))
        end
      end

      def base_uri=(uri = nil)
        @base_uri = uri
      end

      def default_headers
        header = self.class.default_options[:headers] || {}
        header.merge!({"Content-Type" => "application/json"})
        if @session_id
          header = header.merge('X-SESSION_ID' => self.session_id)
        end
        header
      end

      def default_headers=(header_hash)
        self.class.default_options[:headers] = header_hash
      end

      def session_id=(session_id)
        @session_id = session_id
      end

      # login to commonsense
      # @return [String] session_id
      def login(username, password, digest=true)
        if digest
          password = Digest::MD5.hexdigest password
        end
        post('/login.json', {:username => username, :password => password})

        if @response_code == 200
          self.session_id = response_body['session_id']
        else
          self.session_id = false
          @errors = [response_body['error']]
        end

        session_id
      end

      private
      def reset
        @errors = nil
        @response_code = nil
        @response_body = nil
        @request_body = nil
        @request_headers = nil
      end

      def parse_response
        return unless @response_body
        @response_code = @response_body.response.code.to_i
        @response_headers = @response_body.headers
        if @response_code >= 400
          @errors = [response_body['error']]
        end
      end

      def prepare(body=nil, headers={})
        @request_headers = default_headers.merge(headers)
        @request_body = body.to_json

        {:body => @request_body, :headers => @request_headers}
      end
    end
  end
end
