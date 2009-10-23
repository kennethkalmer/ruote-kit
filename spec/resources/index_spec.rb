require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /" do
  it "should return a welcome message in HTML be default" do
    get "/"

    last_response.should be_ok
    last_response.content_type.should match("text/html")

    last_response.should match(/Hello world/)
    last_response.should match(/<title>/)
  end

  it "should return a version string if JSON is requested" do
    header "Accept", "application/json"
    get "/"

    last_response.should be_ok
    last_response.content_type.should match("application/json")
    body = last_response.json_body

    body.should have_key("links")

    body["misc"].should == { "ruote-kit" => "welcome", "version" => RuoteKit::VERSION.to_s }
  end
end

describe "Generic error handling" do
  it "should give our own 404 page" do
    get "/kenneth"

    last_response.should_not be_ok
    last_response.status.should be(404)

    last_response.should match(/Resource not found/)
  end
end
