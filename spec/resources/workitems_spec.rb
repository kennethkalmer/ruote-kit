require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /workitems" do
  describe "without any workitems" do
    it "should report no workitems (HTML)" do
    pending
      get "/workitems"

      last_response.should be_ok
      last_response.should match(/No workitems are available/)

      assigns[:workitems].should be_empty
    end

    it "should report no workitems (JSON)"
  end

  describe "with workitems" do
    it "should have a list of workitems (HTML)"
    it "should have a list of workitems (JSON)"
  end
end

describe "GET /workitems/X-Y" do
  describe "with a workitem" do
    it "should return it (HTML)"
    it "should return it (JSON)"
  end

  describe "without a workitem" do
    it "should return a 404 (HTML)"
    it "should return a 404 (JSON)"
  end
end

describe "PUT /workitems/X-Y" do
  it "should update the workitem fields (HTML)"
  it "should update the workitem fields (JSON)"
  it "should reply to the engine (HTML)"
  it "should reply to the engine (JSON)"
end
