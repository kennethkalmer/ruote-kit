require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /" do
  it "should return a welcome message" do
    get "/"

    last_response.should be_ok
    last_response.should match(/Hello world/)
  end
end
