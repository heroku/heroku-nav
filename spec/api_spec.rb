require File.expand_path('../base', __FILE__)

describe "Api" do
  before do
    RestClient.stubs(:get).returns({ 'html' => '<!-- header -->' }.to_json)
  end

  it "has a resource based on the class name" do
    Heroku::Nav::Header.resource.should == 'header'
    Heroku::Nav::Footer.resource.should == 'footer'
  end

  it "has a resource url based on the api url" do
    Heroku::Nav::Header.resource_url.should == 'https://nav.heroku.com/header'
  end

  it "doesn't raise" do
    RestClient.stubs(:get).raises("error")
    lambda { Heroku::Nav::Header.fetch }.should.not.raise
  end

  it "parses the JSON response, returning the html and css" do
    Heroku::Nav::Header.fetch.should == { 'html' => '<!-- header -->' }
  end
end
