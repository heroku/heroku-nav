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
        insert! if can_insert?(env)
        [@status, @headers, @body]
      end

      def can_insert?(env)
        return unless @options[:status].include?(@status)
        return unless @headers['Content-Type'] =~ /text\/html/ || (@body.respond_to?(:headers) && @body.headers['Content-Type'] =~ /text\/html/)
        @body_accessor = [:first, :body].detect { |m| @body.respond_to?(m) }
        return unless @body_accessor
        return unless @body.send(@body_accessor) =~ /<body.*?>/i
        return if @options[:except].any? { |route| env['PATH_INFO'] =~ route }
        true
      end

      def refresh
        @html = self.class.fetch
      end

      class << self
        def fetch
          Timeout.timeout(4) do
            raw   = RestClient.get(resource_url, :accept => :json)
            attrs = JSON.parse(raw)
            return attrs['html']
          end
        rescue => e
          STDERR.puts "Failed to fetch the Heroku #{resource}: #{e.class.name} - #{e.message}"
          nil
        end

        def resource
          name.split('::').last.downcase
        end

        def resource_url
          [api_url, '/', resource].join
        end

        def api_url
          ENV['API_URL'] || "http://nav.heroku.com"
        end
      end
    end

    class Header < Base
      def insert!
        if @html
          @body.send(@body_accessor).gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/header.css' media='all' rel='stylesheet' type='text/css' />") 
          @body.send(@body_accessor).gsub!(/(<body.*?>\s*(<div .*?class=["'].*?container.*?["'].*?>)?)/i, "\\1#{@html}")
        end
        @headers['Content-Length'] = @body.send(@body_accessor).size.to_s
      end
    end

    class Footer < Base
      def insert!
        if @html
          @body.send(@body_accessor).gsub!(/(<head>)/i, "\\1<link href='#{self.class.api_url}/footer.css' media='all' rel='stylesheet' type='text/css' />") 
          @body.send(@body_accessor).gsub!(/(<\/body>)/i, "#{@html}\\1")
        end
        @headers['Content-Length'] = @body.send(@body_accessor).size.to_s
      end
    end
  end
end
