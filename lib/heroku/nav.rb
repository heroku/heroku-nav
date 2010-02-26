require 'rest_client'
require 'json'

module Heroku
  module Nav
    class Base
      def initialize(app)
        @app = app
        refresh
      end

      def call(env)
        @status, @headers, @body = @app.call(env)
        insert! if can_insert?
        [@status, @headers, @body]
      end

      def can_insert?
        return unless @headers['Content-Type'] =~ /text\/html/ || (@body.respond_to?(:headers) && @body.headers['Content-Type'] =~ /text\/html/)
        @body_accessor = [:first, :body].detect { |m| @body.respond_to?(m) }
        return unless @body_accessor
        return unless @body.send(@body_accessor) =~ /<body.*?>/i
        true
      end

      def refresh
        @html, @css = fetch
      end

      def fetch
        raw   = RestClient.get(resource_url, :accept => :json)
        attrs = JSON.parse(raw)
        [attrs['html'], attrs['css']]
      rescue => e
        STDERR.puts "Failed to fetch the Heroku #{resource}: #{e.class.name} - #{e.message}"
        nil
      end

      def resource
        self.class.name.split('::').last.downcase
      end

      def resource_url
        [api_url, resource].join
      end

      def api_url
        ENV['API_URL'] || "http://nav.heroku.com/"
      end
    end

    class Header < Base
      def insert!
        @body.send(@body_accessor).gsub!(/(<head>)/i, "\\1<style type=\"text/css\">#{@css}</style>") if @css
        @body.send(@body_accessor).gsub!(/(<body.*?>\s*(<div .*?class=["'].*?container.*?["'].*?>)?)/i, "\\1#{@html}") if @html
        @headers['Content-Length'] = @body.send(@body_accessor).size.to_s
      end
    end

    class Footer < Base
      def insert!
        @body.send(@body_accessor).gsub!(/(<head>)/i, "\\1<style type=\"text/css\">#{@css}</style>") if @css
        @body.send(@body_accessor).gsub!(/(<\/body>)/i, "#{@html}\\1") if @html
        @headers['Content-Length'] = @body.send(@body_accessor).size.to_s
      end
    end
  end
end
