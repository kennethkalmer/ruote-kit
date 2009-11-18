require File.dirname(__FILE__) + '/../spec_helper'

describe "/expressions" do
  it "should report a friendly message to the user (HTML)" do
    get "/expressions"

    last_response.should be_ok
  end

  it "should report a friendly message to the client (JSON)" do
    get "/expressions.json"

    last_response.should be_ok

    last_response.json_body['status'].should == 'ok'
  end
end
