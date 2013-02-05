require File.expand_path('../base', __FILE__)

describe Heroku::Nav::Header do

  def app
    make_app { use Heroku::Nav::Header }
  end

  def wrap_stderr(&block)
    original_stderr = $stderr
    $stderr = StringIO.new
    yield
    str = $stderr.string
    $stderr = original_stderr
    str
  end

  url = "https://nav.heroku.com/header"

  before do
    WebMock.reset!
  end

  it "rescues exceptions" do
    stub_request(:get, url).to_timeout
    wrap_stderr do
      get '/', :body => '<html><body>hi'
    end
    last_response.status.should.equal 200
  end

  describe "fetching" do
    before do
      Heroku::Nav::Header.stubs(:fetch).returns('html' => '<!-- header -->')
    end

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
      last_response.body.should.equal "<html><head><link href='https://nav.heroku.com/header.css' media='all' rel='stylesheet' type='text/css' />... <body><!-- header -->"
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
end

describe Heroku::Nav::Footer do
  before do
    Heroku::Nav::Footer.stubs(:fetch).returns('html' => '<!-- footer -->')
  end

  def app
    make_app { use Heroku::Nav::Footer }
  end

  it "adds the html right before the body closing" do
    get '/', :body => '<body>hi</body></html>'
    last_response.body.should.equal '<body>hi<!-- footer --></body></html>'
  end

  it "adds the css right after the head" do
    get '/', :body => '<html><head>... <body>'
    last_response.body.should.equal "<html><head><link href='https://nav.heroku.com/footer.css' media='all' rel='stylesheet' type='text/css' />... <body>"
  end
end

describe Heroku::Nav::Internal do
  before do
    Heroku::Nav::Internal.stubs(:fetch).returns('head' => '<!-- head -->', 'body' => '<!-- body -->')
  end

  def app
    make_app { use Heroku::Nav::Internal }
  end

  it "adds the head" do
    get '/', :body => '<head><title /></head><body>'
    last_response.body.should.equal '<head><!-- head --><title /></head><body>'
  end

  it "adds the body" do
    get '/', :body => '<html><body>hi</body>'
    last_response.body.should.equal '<html><body>hi<!-- body --></body>'
  end
end

describe Heroku::Nav::Provider do
  before do
    Heroku::Nav::Provider.stubs(:fetch).returns('<!-- heroku header -->')
  end

  describe "when there's no heroku-nav-data cookie" do
    def app
      make_app { use Heroku::Nav::Provider }
    end

    it "doesn't add the body" do
      get '/', :body => '<html><body>hi</body>'
      last_response.body.should.equal '<html><body>hi</body>'
    end
  end

  describe "when there's a heroku-nav-data cookie" do
    before do
      set_cookie("heroku-nav-data=data")
    end

    def app
      make_app { use Heroku::Nav::Provider }
    end

    it "adds the body" do
      get '/', :body => '<html><body>hi</body>'
      last_response.body.should.equal '<html><body><!-- heroku header -->hi</body>'
    end

    it "doesn't add if there is no body tag" do
      get '/', :body => 'no body!'
      last_response.body.should.equal 'no body!'
    end

    describe "special chars" do
      before do
        Heroku::Nav::Provider.stubs(:fetch).returns('<!-- \+ nav -->')
      end

      def app
        make_app { use Heroku::Nav::Provider }
      end

      # tricky situation, the first implementation of Heroku::Nav would inject the
      # html by using gsub. That worked out alright until the html got a sequence of
      # chars like "\+". those got interpreted by gsub and resulted in a bad output
      it "doesn't freakout if the header contains special chars relevant to Ruby's gsub" do
        get '/', :body => '<html><body>hi</body>'
        last_response.body.should.equal '<html><body><!-- \+ nav -->hi</body>'
      end
    end
  end
end
