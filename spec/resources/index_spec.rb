require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /", :type => :with_engine do

  it "should return a welcome message in HTML be default" do
    get "/_ruote"

    last_response.should be_ok
    last_response.content_type.should match("text/html")

    last_response.should match(/Hello world/)
    last_response.should match(/<title>/)
  end

  it "should return a version string if JSON is requested" do
    header "Accept", "application/json"

    get "/_ruote"

    last_response.should be_ok
    last_response.content_type.should match("application/json")
    body = last_response.json_body

    body["misc"].should == { "ruote-kit" => "welcome", "version" => RuoteKit::VERSION.to_s }
  end
end

describe "Generic error handling", :type => :with_engine do

  it "should give our own 404 page (HTML)" do
    get "/kenneth"

    last_response.should_not be_ok
    last_response.status.should be(404)

    last_response.should be_html
    last_response.should match(/Resource not found/)
  end

  it "should give our own 404 data (JSON)" do
    get "/kenneth.json"

    last_response.should_not be_ok
    last_response.status.should be(404)

    last_response.should be_json
  end
end
