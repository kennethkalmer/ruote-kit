require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /_ruote/participants" do

  describe "without any participant" do

    it_has_an_engine_with_no_participants

    it "should give an empty list (HTML)" do
      get "/_ruote/participants"

      last_response.should be_ok
    end

    it "should give an empty array (JSON)" do
      get "/_ruote/participants.json"

      last_response.should be_ok

      body = last_response.json_body
      body.should have_key("participants")

      body["participants"].should be_empty
    end
  end

  describe "with participant" do

    it_has_an_engine

    it "should give participant information back (HTML)" do
      get "/_ruote/participants"

      last_response.should be_ok
    end

    it "should give participant information back (JSON)" do
      get "/_ruote/participants.json"

      last_response.should be_ok

      body = last_response.json_body

      body["participants"].should_not be_empty
    end
  end
end

describe "GET /_ruote/participants/:name", :type => :with_engine do

  describe "without registered participants" do

    it_has_an_engine_with_no_participants
    
    it "should 404 correctly (HTML)" do
      get "/_ruote/participants/foo"

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.should match(/Resource not found/)
    end

    it "should 404 correctly (JSON)" do
      get "/_ruote/participants/foo.json"

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.json_body.keys.should include("error")
      last_response.json_body['error'].should == { "code" => 404, "message" => "Resource not found" }
    end
  end

  describe "with registered participants" do

    it_has_an_engine_with_no_participants

    before :each do
      @name = 'foo'

      RuoteKit.engine.register do
        participant @name, Ruote::NoOpParticipant
        catchall Ruote::StorageParticipant
      end
    end

    it "should give participant information back (HTML)" do
      get "/_ruote/participants/#{@name}"

      last_response.should be_ok
    end

    it "should give process information back (JSON)" do
      get "/_ruote/participants/#{@name}.json"

      last_response.should be_ok

      body = last_response.json_body

      body.should have_key('participant')
    end
  end
end