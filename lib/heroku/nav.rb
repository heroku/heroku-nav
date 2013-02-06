require 'okjson'
require 'net/https'
require 'timeout'

module Heroku
  module Nav
    class Base
      def initialize(app, options={})
        @app     = app
        @options = options
        @options[:except] = [@options[:except]] unless @options[:except].is_a?(Array)
        @options[:status] ||= [200]
        refresh
      end

      def call(env)
        @status, @headers, @body = @app.call(env)
        @body.extend(Enumerable)
        @body = @body.to_a.join
        insert! if can_insert?(env)
        [@status, @headers, [@body]]
      end

      def can_insert?(env)
        return unless @options[:status].include?(@status)
        return unless @headers['Content-Type'] =~ /text\/html/ || @headers['content-type'] =~ /text\/html/
        return if @options[:except].any? { |route| env['PATH_INFO'] =~ route }
        true
      end

      def refresh
        @nav = self.class.fetch
      end

      class << self
        def fetch(format = 'application/json')
          uri = URI.parse(resource_url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme == 'https'
          request = Net::HTTP::Get.new(uri.request_uri)
          request['Accept'] = format
          timeout = (ENV['HEROKU_NAV_TIMEOUT'] || 10).to_i
          response = Timeout.timeout(timeout) do
            retry_upto(timeout, :interval => 0.5) do
              http.request(request)
            end
          end
          format == 'application/json' ? OkJson.decode(response.body) : response.body
        rescue Timeout::Error, StandardError => e
          $stderr.puts "Failed to fetch the Heroku #{resource}: #{e.class.name} - #{e.message}"
          {}
        end

        def resource
          name.split('::').last.downcase
        end

        def resource_url
          [api_url, '/', resource].join
        end

        def api_url
          ENV['API_URL'] || ENV['HEROKU_NAV_URL'] || "https://nav.heroku.com"
        end

        # for non-rack use
        def html
          @@body ||= fetch['html']
        end

        def retry_upto(max_retries = 1, opts = {})
          yield
        rescue Timeout::Error, StandardError
          attempt = attempt ? attempt+1 : 1
          raise if (attempt == max_retries)
          if interval = opts[:interval]
            secs = interval.respond_to?(:call) ? interval.call(attempt) : interval
            sleep(secs)
          end
          retry
        end
      end
    end

    class Header < Base
      def insert!
        if @nav['html']
          @body.gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/header.css' media='all' rel='stylesheet' type='text/css' />")
          @body.gsub!(/(<body.*?>\s*(<div .*?class=["'].*?container.*?["'].*?>)?)/i, "\\1#{@nav['html']}")
          @headers['Content-Length'] = Rack::Utils.bytesize(@body).to_s
        end
      end
    end

    class Footer < Base
      def insert!
        if @nav['html']
          @body.gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/footer.css' media='all' rel='stylesheet' type='text/css' />")
          @body.gsub!(/(<\/body>)/i, "#{@nav['html']}\\1")
          @headers['Content-Length'] = Rack::Utils.bytesize(@body).to_s
        end
      end
    end

    class Internal < Base
      def self.resource
        "internal.json"
      end
      def insert!
        if @nav['head']
          @body.gsub!(/(<head>)/i, "\\1#{@nav['head']}")
        end
        if @nav['body']
          @body.gsub!(/(<\/body>)/i, "#{@nav['body']}\\1")
        end
        @headers['Content-Length'] = Rack::Utils.bytesize(@body).to_s
      end
    end

    class Provider < Base
      class << self

        def fetch
          super('text/html')
        end

        def resource_url
          "#{api_url}/v1/providers/header"
        end

        # for non-rack use
        def html
          @@body ||= fetch
        end
      end

      def can_insert?(env)
        super && env['HTTP_COOKIE'] && env['HTTP_COOKIE'].include?('heroku-nav-data')
      end

      def insert!
        if @nav
          match = @body.match(/(\<body[^\>]*\>)/i)
          if match && match.size > 0
            @body.insert(match.end(0), @nav)
            @headers['Content-Length'] = Rack::Utils.bytesize(@body).to_s
          end
        end
      end
    end
  end
end
