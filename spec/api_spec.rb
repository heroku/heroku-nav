require File.dirname(__FILE__) + '/base'

describe "Api" do
  before do
    RestClient.stubs(:get).returns({ :html => '<!-- header -->', :css => '#header' }.to_json)
    @header = Heroku::Nav::Header.new(:app)
  end

  it "has a resource based on the class name" do
    @header.resource.should == 'header'
  end

  it "has a resource url based on the api url" do
    @header.resource_url.should == 'http://nav.heroku.com/header'
  end

  it "doesn't raise" do
    RestClient.stubs(:get).raises("error")
    lambda { @header.fetch }.should.not.raise
  end

  it "parses the JSON response, returning the html and css" do
    @header.fetch.should == ['<!-- header -->', '#header']
  end
end