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
      body["processes"].first['wfid'].should == @wfid
    end
  end
end

describe "GET /processes/X-Y" do
  describe "with a running process" do
    before(:each) do
      @wfid = launch_test_process
    end

    it "should give process information back (HTML)" do
      get "/processes/#{@wfid}"

      last_response.should be_ok

      last_response.should match( @wfid )
    end

    it "should give process information back (JSON)" do
      get "/processes/#{@wfid}.json"

      last_response.should be_ok

      body = last_response.json_body

      # We should have more links, including 'self' and history...
      body['links'].size.should be(6)
      body['links'].should include({ 'href' => "/processes/#{@wfid}", 'rel' => 'self' })
      body['links'].should include({
        'href' => "/history/#{@wfid}", 'rel' => 'http://ruote.rubyforge.org/rels.html#process_history'
      })

      body['process'].should == RuoteKit.engine.process( @wfid ).to_h
    end
  end

  describe "without a running process" do
    it "should 404 correctly (HTML)" do
      get "/processes/foo"

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.should match(/Resource not found/)
    end

    it "should 404 correctly (JSON)" do
      get "/processes/foo.json"

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.json_body.keys.should include("error")
      last_response.json_body['error'].should == { "code" => "404", "message" => "Resource not found" }
    end
  end
end

describe "POST /processes" do
  it "should launch a valid process" do
    pdef = Ruote.process_definition :name => 'test' do
      _sleep '2s'
    end

    post '/processes.json', pdef.to_json, { 'CONTENT_TYPE' => 'application/json' }

    last_response.should be_redirect
    last_response['Location'].should match( /^\/processes\/[0-9a-z\-]+\.json$/ )

    sleep 0.4

    RuoteKit.engine.processes.should_not be_empty
  end
end

describe "DELETE processes" do
  before(:each) do
    @wfid = launch_test_process do
      Ruote.process_definition :name => 'test' do
        sequence :on_cancel => 'bail_out' do
          echo "done."
          wait '1d'
        end

        define :name => 'bail_out' do
          echo "bailout."
        end
      end
    end
  end

  it "should cancel processes" do
    delete "/processes/#{@wfid}.json"

    last_response.should be_ok

    sleep 0.4

    RuoteKit.engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done.\nbailout."
  end

  it "should kill processes" do
    delete "/processes/#{@wfid}.json?kill=1"

    last_response.should be_ok

    sleep 0.4

    RuoteKit.engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done."
  end
end
