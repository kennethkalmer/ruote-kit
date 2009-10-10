require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /" do
  it "should return a welcome message in HTML be default" do
    get "/"

    last_response.should be_ok
    last_response.should match(/Hello world/)
    last_response.content_type.should match("text/html")
  end

  it "should return a version string if JSON is requested" do
    header "Accept", "application/json"
    get "/"

    last_response.should be_ok
    last_response.content_type.should match("application/json")
    last_response.json_body.should == { "ruote-kit" => "welcome", "version" => RuoteKit::VERSION.to_s }
  end
end
