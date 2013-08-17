module CS
  class Session
    attr_accessor :logger, :base_uri

    def initialize(opts={})
      options = {
        base_uri: 'https://api.sense-os.nl',
        authentication: true
      }.merge(opts)
      @base_uri = options[:base_uri]
      @auth_proxy = options[:authentication] ? nil : CS::Auth::HTTP.new(@base_uri)
    end

    # login to commonsense
    # @return [String] session_id
    def login(username, password)
      @auth_proxy = CS::Auth::HTTP.new(@base_uri)
      @auth_proxy.login(username, password)
    end

    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @auth_proxy = CS::Auth::OAuth.new(consumer_key, consumer_secret,
                                                 access_token, access_token_secret,
                                                 @base_uri)
    end

    def session_id
      auth_proxy.session_id
    end

    def session_id=(session_id)
      @auth_proxy = CS::Auth::HTTP.new(@base_uri)
      @auth_proxy.session_id = session_id
    end

    def auth_proxy
      raise 'The session is not logged in' unless @auth_proxy
      @auth_proxy
    end

    def retry_on_509(&block)
      while true
        response = yield
        if response_code == 509
          waitfor = Random.new.rand(30..45)
          logger.info "limit reached. waiting for #{waitfor} before retrying" if logger
          sleep(waitfor)
        else
          return response
        end
      end
    end

    def log_request(type, path, body, headers)
      logger.info("")
      logger.info("#{type} #{path}")
      logger.debug("headers: #{headers.inspect}")
      logger.info("parameters: #{body.inspect}")
    end

    def log_response
      logger.info("response: #{self.response_code}")
      logger.debug("body: #{self.response_body}")
    end

    def execute(type, path, body, headers, &block)
      log_request(type, path, body, headers) if logger
      response = retry_on_509 { yield }
      log_response if logger

      response
    end

    def get(path, body = '', headers = {})
      execute("GET", path, body, headers) do
        auth_proxy.get(path, body, headers)
      end
    end

    def post(path, body = '', headers = {})
      execute("POST", path, body, headers) do
        auth_proxy.post(path, body, headers = {})
      end
    end

    def put(path, body = '', headers = {})
      execute("PUT", path, body, headers) do
        auth_proxy.put(path, body, headers)
      end
    end

    def delete(path, body='', headers = {})
      execute("DELETE", path, body, headers) do
        auth_proxy.delete(path, body, headers)
      end
    end

    def head(path, headers = {})
      execute("HEAD", path, nil, headers) do
        auth_proxy.head(path, headers)
      end
    end

    def response_code
      auth_proxy.response_code
    end

    def response_body
      auth_proxy.response_body
    end

    def response_headers
      auth_proxy.response_headers
    end

    def errors
      auth_proxy.errors
    end

    def base_uri=(uri = nil)
      auth_proxy.base_uri = uri
    end

    def dump_to_text(path)
      File.open(path, 'w') do |f|
        f.write("Response Code: #{response_code}\n")
        f.write("Response Headers: #{response_headers}\n")
        f.write("Errors: #{errors}\n")
        f.write("\n")
        f.write(response_body)
      end
    end

    def open_in_browser(path=nil)
      require 'launchy'

      path ||= "/tmp/common-sense-ruby-#{Time.now.to_i}.html"
      dump_to_text(path)
      ::Launchy::Browser.run(path)
    end

    def to_s
      "\"#{self.session_id}\""
    end

    def inspect
      auth_proxy.kind_of?(CS::Auth::HTTP) ? to_s : "OAuth"
    end
  end
end
