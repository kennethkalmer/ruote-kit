require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /processes" do
  describe "without any running processes" do
    it "should give no processes back (HTML)" do
      get "/processes"

      last_response.should be_ok
    end

    it "should give an empty array (JSON)" do
      get "/processes.json"

      last_response.should be_ok

      body = last_response.json_body
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
    end

    it "should give process information back (JSON)" do
      get "/processes.json"

      last_response.should be_ok

      body = last_response.json_body

      body["processes"].should_not be_empty
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
    end

    it "should give process information back (JSON)" do
      get "/processes/#{@wfid}.json"

      last_response.should be_ok

      body = last_response.json_body

      body.should have_key('process')
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

describe "GET /processes/new" do
  it "should return a launch form" do
    get "/processes/new"

    last_response.should be_ok
  end
end

describe "POST /processes" do
  before(:each) do
    engine.processes.should be_empty
  end

  it "should launch a valid process definition (JSON)" do
    params = {
      :definition => %q{Ruote.process_definition :name => 'test' do
        _sleep '1m'
      end}
    }

    post '/processes.json', params.to_json, { 'CONTENT_TYPE' => 'application/json' }

    last_response.should be_redirect
    last_response['Location'].should match( /^\/processes\/[0-9a-z\-]+\.json$/ )
    #last_response['Content-Type'].should be_nil

    sleep 0.4

    engine.processes.should_not be_empty
  end

  it "should launch a valid process definition with fields (JSON)" do
    params = {
      :definition => %q{Ruote.process_definition :name => 'test' do
        echo '${f:foo}'
      end},
      :fields => { :foo => 'bar' }
    }

    post '/processes.json', params.to_json, { 'CONTENT_TYPE' => 'application/json' }

    last_response.should be_redirect
    last_response['Location'].should match( /^\/processes\/([0-9a-z\-]+)\.json$/ )

    engine.context[:s_logger].wait_for([
      [ :processes, :terminated, { :wfid => $1 } ],
      [ :errors, nil, { :wfid => $1 } ]
    ])

    @tracer.to_s.should == "bar"
  end

  it "should launch a valid process definition (HTML)" do
    params = {
      :process_definition => %q{Ruote.process_definition :name => "test" do
        _sleep '1m'
      end
      }
    }

    post "/processes", params

    last_response.should be_redirect
    last_response['Location'].should match( /^\/processes\/[0-9a-z\-]+$/ )

    sleep 0.4

    engine.processes.should_not be_empty
  end

  it "should launch a process definition with fields (HTML)" do
    params = {
      :process_definition => %q{Ruote.process_definition :name => 'test' do
        echo '${f:foo}'
      end},
      :process_fields => %q{ { "foo": "bar" } }
    }

    post '/processes', params

    last_response.should be_redirect
    last_response['Location'].should match( /^\/processes\/([0-9a-z\-]+)$/ )

    engine.context[:s_logger].wait_for([
      [ :processes, :terminated, { :wfid => $1 } ],
      [ :errors, nil, { :wfid => $1 } ]
    ])

    @tracer.to_s.should == "bar"
  end

  it "should correct for empty fields sent by browsers" do
    params = {
      :process_definition => %q{Ruote.process_definition :name => 'test' do
        wait '5m'
      end},
      :process_fields => ''
    }

    post '/processes', params

    last_response.should be_redirect

    sleep 0.4

    engine.processes.should_not be_empty
  end
end

describe "DELETE /processes/X-Y" do
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

  it "should cancel processes (JSON)" do
    delete "/processes/#{@wfid}.json"

    last_response.should be_ok

    sleep 0.4

    engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done.\nbailout."
  end

  it "should cancel processes (HMTL)" do
    delete "/processes/#{@wfid}"

    last_response.should be_redirect
    last_response['Location'].should == "/processes"

    sleep 0.4

    engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done.\nbailout."
  end

  it "should kill processes (JSON)" do
    delete "/processes/#{@wfid}.json?_kill=1"

    last_response.should be_ok

    sleep 0.4

    engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done."
  end

  it "should kill processes (HTML)" do
    delete "/processes/#{@wfid}?_kill=1"

    last_response.should be_redirect
    last_response['Location'].should == '/processes'

    sleep 0.4

    engine.process( @wfid ).should be_nil

    @tracer.to_s.should == "done."
  end
end
