require 'rest_client'
require 'json'
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
        @body = @body.map.join
        insert! if can_insert?(env)
        [@status, @headers, [@body]]
      end

      def can_insert?(env)
        return unless @options[:status].include?(@status)
        return unless @headers['Content-Type'] =~ /text\/html/
        return if @options[:except].any? { |route| env['PATH_INFO'] =~ route }
        true
      end

      def refresh
        @nav = self.class.fetch
      end

      class << self
        def fetch
          Timeout.timeout(4) do
            raw = RestClient.get(resource_url, :accept => :json).to_s
            return JSON.parse(raw)
          end
        rescue => e
          STDERR.puts "Failed to fetch the Heroku #{resource}: #{e.class.name} - #{e.message}"
          {}
        end

        def resource
          name.split('::').last.downcase
        end

        def resource_url
          [api_url, '/', resource].join
        end

        def api_url
          ENV['API_URL'] || ENV['HEROKU_NAV_URL'] || "http://nav.heroku.com"
        end

        # for non-rack use
        def html
          @@body ||= fetch['html']
        end
      end
    end

    class Header < Base
      def insert!
        if @nav['html']
          @body.gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/header.css' media='all' rel='stylesheet' type='text/css' />") 
          @body.gsub!(/(<body.*?>\s*(<div .*?class=["'].*?container.*?["'].*?>)?)/i, "\\1#{@nav['html']}")
          @headers['Content-Length'] = @body.length.to_s
        end
      end
    end

    class Footer < Base
      def insert!
        if @nav['html']
          @body.gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/footer.css' media='all' rel='stylesheet' type='text/css' />") 
          @body.gsub!(/(<\/body>)/i, "#{@nav['html']}\\1")
          @headers['Content-Length'] = @body.length.to_s
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
        @headers['Content-Length'] = @body.length.to_s
      end
    end

    class Provider < Base
      class << self
        def fetch
          Timeout.timeout(4) do
            RestClient.get(resource_url).to_s
          end
        rescue => e
          STDERR.puts "Failed to fetch the Heroku #{resource}: #{e.class.name} - #{e.message}"
          {}
        end

        def resource_url
          "#{api_url}/v1/providers/header"
        end

        # for non-rack use
        def html
          @@body ||= fetch
        end
      end

      def insert!
        if @nav
          match = @body.match(/(\<body[^\>]*\>)/i)
          if match.size > 0
            @body.insert(match.end(0), @nav)
            @headers['Content-Length'] = @body.length.to_s
          end
        end
      end
    end
  end
end
