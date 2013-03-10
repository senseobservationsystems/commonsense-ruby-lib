require "httparty"

module CommonSense
  module Auth
    class HTTP
      include HTTParty

      attr_accessor :response_body, :response_code, :response_headers, :errors
      attr_reader :session_id

      def initialize(base_uri = nil)
        self.base_uri = base_uri
        @session_id = nil
        reset
      end

      def get(path, headers = {})
        reset
        options = prepare(nil, headers) 
        @response_body = self.class.get(path, options)
        parse_response
        @response_body
      end

      def post(path, body = '', headers = {})
        reset
        @response_body = self.class.post(path, prepare(body, headers))
        parse_response
        @response_body
      end

      def put(path, body = '', headers = {})
        reset
        @response_body = self.class.put(path, prepare(body, headers))
        parse_response
        @response_body
      end

      def delete(path, headers = {})
        params = prepare(path, nil, headers)
        @response_body = self.class.delete(path, prepare(nil, headers))
        parse_response
        @response_body
      end

      def head(path, headers = {})
        reset
        @response_body = self.class.head(path, prepare(nil, headers))
        parse_response
        @response_body
      end

      def base_uri=(uri = nil)
        self.class.base_uri uri
      end

      def default_headers
        self.class.default_options[:headers] || {}
      end

      def default_headers=(header_hash)
        self.class.default_options[:headers] = header_hash
      end

      def session_id=(session_id)
        @session_id = session_id
        headers = default_headers
        headers.merge!('X-SESSION_ID' => self.session_id)
        self.default_headers = headers
      end


      # login to commonsense
      # @return [String] session_id
      def login(username, password)
        password = Digest::MD5.hexdigest password
        post('/login.json', {:username => username, :password => password})

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

      def parse_response
        @response_code = @response_body.response.code.to_i
        @response_headers = @response_body.headers
        if @response_code >= 400
          @errors = [response_body['error']]
        end
      end

      def prepare(body=nil, headers={})
        headers = default_headers.merge(headers)
        {:query => body, :headers => headers}
      end
    end
  end
end
