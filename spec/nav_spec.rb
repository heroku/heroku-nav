require File.dirname(__FILE__) + '/base'

class Heroku::Nav::Header
  def fetch
    ['<!-- header -->', '#header']
  end
end

class Heroku::Nav::Footer
  def fetch
    ['<!-- footer -->', '#footer']
  end
end

describe Heroku::Nav::Header do
  def app
    make_app { use Heroku::Nav::Header }
  end

  it "doesn't apply if content-type is not html" do
    get '/text', :body => '<html><body>hi'
    last_response.body.should.equal '<html><body>hi'
  end

  it "adds the html right after the body" do
    get '/', :body => '<html><body>hi'
    last_response.body.should.equal '<html><body><!-- header -->hi'
  end

  it "adds the html right after the body, even if it has properties" do
    get '/', :body => '<html><body id="a" class="b">hi'
    last_response.body.should.equal '<html><body id="a" class="b"><!-- header -->hi'
  end

  it "adds the html right after the first div if class is container" do
    get '/', :body => '<html><body><div class="container">hi</div>'
    last_response.body.should.equal '<html><body><div class="container"><!-- header -->hi</div>'
  end

  it "adds the css right after the head" do
    get '/', :body => '<html><head>... <body>'
    last_response.body.should.equal '<html><head><style type="text/css">#header</style>... <body><!-- header -->'
  end

  describe "excluding paths" do
    def app
      make_app { use Heroku::Nav::Header, :except => [/x/, /alt/] }
    end

    it "respects the :except option" do
      get '/alternate', :body => '<html><body>hi'
      last_response.body.should.equal '<html><body>hi'
    end
  end
end

describe Heroku::Nav::Footer do
  def app
    make_app { use Heroku::Nav::Footer }
  end

  it "adds the html right before the body closing" do
    get '/', :body => '<body>hi</body></html>'
    last_response.body.should.equal '<body>hi<!-- footer --></body></html>'
  end

  it "adds the css right after the head" do
    get '/', :body => '<html><head>... <body>'
    last_response.body.should.equal '<html><head><style type="text/css">#footer</style>... <body>'
  end
end
