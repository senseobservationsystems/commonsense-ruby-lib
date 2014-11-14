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
    def login(username, password, digest=true)
      @auth_proxy = CS::Auth::HTTP.new(@base_uri)
      @auth_proxy.logger = self.logger
      @auth_proxy.login(username, password, digest)
    end

    def oauth(consumer_key, consumer_secret, access_token, access_token_secret)
      @auth_proxy = CS::Auth::OAuth.new(consumer_key, consumer_secret,
                                                 access_token, access_token_secret,
                                                 @base_uri)
      @auth_proxy.logger = self.logger if @auth_proxy
      @auth_proxy
    end

    def session_id
      auth_proxy.session_id
    end

    def api_key
      auth_proxy.api_key
    end

    def session_id=(session_id)
      @auth_proxy = CS::Auth::HTTP.new(@base_uri)
      @auth_proxy.session_id = session_id
    end

    def api_key=(api_key)
      @api_key = api_key
      @auth_proxy = CS::Auth::HTTP.new(@base_uri, api_key)
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

    def log_request(type, path)
      logger.info("")
      logger.info("#{type} #{path}")
      logger.debug("headers: #{@auth_proxy.request_headers.inspect}")
      if ["POST", "PUT"].include?(type)
        logger.debug("request: #{@auth_proxy.request_body.inspect}")
      else
        logger.info("request: #{@auth_proxy.request_body.inspect}")
      end
    end

    def log_response(elapsed)
      logger.info("result: #{self.response_code} in #{elapsed}ms")
      logger.debug("response: #{self.response_body}")
    end

    def execute(type, path, body, headers, &block)
      start_time = Time.now
      response = retry_on_509 do
        value = yield
        log_request(type, path) if logger
        value
      end

      elapsed = (Time.now - start_time) * 1000.0
      log_response(elapsed) if logger

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
      @base_uri = uri
      auth_proxy.base_uri = uri if @auth_proxy
    end

    def dump_to_text(path)
      begin
        body = response_body.to_s
      rescue Exception => e
        body = e.message
      end

      File.open(path, 'w') do |f|
        f.write("Response Code: #{response_code}\n")
        f.write("Response Headers: #{response_headers}\n")
        f.write("Errors: #{errors}\n")
        f.write("\n")
        f.write(body)
      end
    end

    def open_in_browser(path=nil)
      require 'launchy'

      path ||= "/tmp/common-sense-ruby-#{Time.now.to_i}.html"
      dump_to_text(path)
      ::Launchy::Browser.run(path)
    end

    def to_s
      if session_id
        return "SESSION_ID \"#{session_id}\""
      elsif api_key
        return "API_KEY \"#{api_key}\""
      end
      return ""
    end

    def inspect
      auth_proxy.kind_of?(CS::Auth::HTTP) ? to_s : "OAuth"
    end
  end
end
