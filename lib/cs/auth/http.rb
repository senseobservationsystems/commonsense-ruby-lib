require "httparty"
require "json"

module CS
  module Auth
    class HTTP
      include HTTParty

      attr_accessor :response_body, :response_code, :response_headers, :errors
      attr_reader :session_id, :api_key

      def initialize(base_uri = nil, api_key = nil)
        self.base_uri = base_uri
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

      def get(path, query={}, headers = {})
        execute do
          headers = default_headers.merge(headers)
          options = {query: query, headers: headers}
          path = process_api_key(path)
          self.class.get(path, options)
        end
      end

      def post(path, body = '', headers = {})
        execute do
          headers = default_headers.merge(headers)
          self.class.post(path, prepare(body, headers))
        end
      end

      def put(path, body = '', headers = {})
        execute do
          headers = default_headers.merge(headers)
          self.class.put(path, prepare(body, headers))
        end
      end

      def delete(path, query={}, headers = {})
        execute do
          headers = default_headers.merge(headers)
          options = {query: query, headers: headers}
          self.class.delete(path, options)
        end
      end

      def head(path, headers = {})
        execute do
          self.class.head(path, prepare(nil, headers))
        end
      end

      def base_uri=(uri = nil)
        self.class.base_uri uri
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
      def login(username, password)
        password = Digest::MD5.hexdigest password
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
        headers = default_headers.merge(headers)
        {:body => body.to_json, :headers => headers}
      end
    end
  end
end
