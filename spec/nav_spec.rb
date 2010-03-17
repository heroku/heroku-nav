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
    last_response.body.should.equal "<html><head><link href='http://nav.heroku.com/header.css' media='all' rel='stylesheet' type='text/css' />... <body><!-- header -->"
  end

  it "doesn't add for non 200 responses" do
    get '/404', :body => '<html><body>hi'
    last_response.body.should.not =~ /<!-- header -->/
  end

  describe "defining response status" do
    def app
      make_app { use Heroku::Nav::Header, :status => [404] }
    end

    it "respects the :status option" do
      get '/404', :body => '<html><body>hi'
      last_response.body.should =~ /<!-- header -->/
    end

    it "allows overriding the default status" do
      get '/', :body => '<html><body>hi'
      last_response.body.should.not =~ /<!-- header -->/
    end
  end

  describe "excluding paths" do
    def app
      make_app { use Heroku::Nav::Header, :except => [/x/, /alt/] }
    end

    it "respects the :except option" do
      get '/alternate', :body => '<html><body>hi'
      last_response.body.should.not =~ /<!-- header -->/
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
    last_response.body.should.equal "<html><head><link href='http://nav.heroku.com/footer.css' media='all' rel='stylesheet' type='text/css' />... <body>"
  end
end
