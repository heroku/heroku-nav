require File.expand_path('../base', __FILE__)

describe "Api" do

  url = "https://nav.heroku.com/header"

  before do
    WebMock.reset!
    stub_request(:get, url).
      to_return(:body => OkJson.encode({ 'html' => '<!-- header -->' }))
  end

  it "has a resource based on the class name" do
    Heroku::Nav::Header.resource.should == 'header'
    Heroku::Nav::Footer.resource.should == 'footer'
  end

  it "has a resource url based on the api url" do
    Heroku::Nav::Header.resource_url.should == url
  end

  it "doesn't raise a timeout error" do
    stub_request(:get, url).to_timeout
    stderr = wrap_stderr do
      Heroku::Nav::Header.fetch.should == {}
    end
    stderr.should == "Failed to fetch the Heroku header: Timeout::Error - execution expired\n"
  end

  it "raise signals/interrupts" do
    stub_request(:get, url).to_raise(::Interrupt)
    wrap_stderr do
      lambda { Heroku::Nav::Header.fetch }.should.raise(::Interrupt)
    end
  end

  it "parses the JSON response, returning the html and css" do
    Heroku::Nav::Header.fetch.should == { 'html' => '<!-- header -->' }
  end
end
