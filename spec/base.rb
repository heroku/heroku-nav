$: << File.dirname(__FILE__) + '/../lib'

ENV['HEROKU_NAV_TIMEOUT'] = '1'

require 'heroku/nav'
require 'sinatra/base'
require 'bacon'
require 'mocha/api'
require 'webmock'
require 'rack/test'

class TestApp < Sinatra::Base
  set :environment, :test

  def self.body
    @@body
  end

  def self.body=(body)
    @@body = body
  end

  get '/' do
    params[:body]
  end

  get '/404' do
    [404, "<html><body>404"]
  end

  get '/alternate' do
    params[:body]
  end

  get '/text' do
    content_type 'text/plain'
    params[:body]
  end
end

# tiny factory to help making a Sinatra::Base application.
# whatever is passed in the block will get eval'ed into the class
# Make sure Rack::Test methods are available for all specs
class Bacon::Context
  include ::Rack::Test::Methods
  include ::Mocha::API
  include ::WebMock::API

  def make_app(&blk)
    handler = Class.new(TestApp)
    handler.class_eval(&blk)
    handler
  end

  def wrap_stderr(&block)
    original_stderr = $stderr
    $stderr = StringIO.new
    yield
    str = $stderr.string
    $stderr = original_stderr
    str
  end
end
