require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /processes" do
  describe "without any running processes" do
    it "should give no processes back (HTML)" do
      get "/processes"

      last_response.should be_ok
      last_response.should match(/No processes are currently running/)
    end

    it "should give an empty array (JSON)" do
      get "/processes.json"

      last_response.should be_ok

      body = last_response.json_body
      body.should have_key("links")
      body.should have_key("processes")

      body["processes"].should be_empty
    end
  end

  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process
    end

    it "should give process information back (HTML)" do
      get "/processes"

      last_response.should be_ok
      last_response.should match(/Currently running 1 processes/)
    end

    it "should give process information back (JSON)" do
      get "/processes.json"

      last_response.should be_ok

      body = last_response.json_body

      body["processes"].should_not be_empty
    end
  end
end
