
require File.dirname(__FILE__) + '/../spec_helper'

def process_links(wfid)
  [
    { 'href' => "/_ruote/processes/#{wfid}",
      'rel' => 'self' },
    { 'href' => "/_ruote/processes/#{wfid}",
      'rel' => 'http://ruote.rubyforge.org/rels.html#process' },
    { 'href' => "/_ruote/expressions/#{wfid}",
      'rel' => 'http://ruote.rubyforge.org/rels.html#process_expressions' },
    { 'href' => "/_ruote/workitems/#{wfid}",
      'rel' => 'http://ruote.rubyforge.org/rels.html#process_workitems' },
    { 'href' => "/_ruote/errors/#{wfid}",
      'rel' => 'http://ruote.rubyforge.org/rels.html#process_errors' }
  ]
end


describe 'GET /_ruote/processes' do

  it_has_an_engine

  describe 'without any running processes' do

    it 'should give no processes back (HTML)' do

      get '/_ruote/processes'

      last_response.should be_ok
    end

    it 'should give an empty array (JSON)' do

      get '/_ruote/processes.json'

      last_response.should be_ok

      body = last_response.json_body
      body.should have_key('processes')

      body['processes'].should be_empty
    end
  end

  describe 'with running processes' do

    before(:each) do
      @wfid = launch_test_process
    end

    it 'should give process information back (HTML)' do

      get '/_ruote/processes'

      last_response.should be_ok
    end

    it 'should give process information back (JSON)' do

      get '/_ruote/processes.json'

      last_response.should be_ok

      body = last_response.json_body

      body['processes'].should_not be_empty

      body['links'].should == root_links('/_ruote/processes')
      body['processes'].first['links'].should == process_links(@wfid)
    end
  end
end

describe 'GET /_ruote/processes/X-Y' do

  it_has_an_engine

  describe 'with a running process' do

    before(:each) do
      @wfid = launch_test_process
    end

    it 'should give process information back (HTML)' do

      get "/_ruote/processes/#{@wfid}"

      last_response.should be_ok
    end

    it 'should give process information back (JSON)' do

      get "/_ruote/processes/#{@wfid}.json"

      last_response.should be_ok

      body = last_response.json_body

      body.should have_key('process')

      body['process']['links'].should == process_links(@wfid)
    end
  end

  describe 'without a running process' do

    it 'should 404 correctly (HTML)' do

      get '/_ruote/processes/foo'

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.should match(/resource not found/)
    end

    it 'should 404 correctly (JSON)' do

      get '/_ruote/processes/foo.json'

      last_response.should_not be_ok
      last_response.status.should be(404)

      last_response.json_body.keys.should include('error')

      last_response.json_body['error'].should == {
        'code' => 404, 'message' => 'resource not found' }
    end
  end
end

describe 'GET /_ruote/processes/new' do

  it_has_an_engine

  it 'should return a launch form' do
    get '/_ruote/processes/new'

    last_response.should be_ok
  end
end

describe 'POST /_ruote/processes' do

  it_has_an_engine

  before(:each) do
    engine.processes.should be_empty
  end

  it 'should launch a valid process definition (JSON)' do

    params = {
      :definition => %q{
        Ruote.process_definition :name => 'test' do
          wait '1m'
        end
      }
    }

    post(
      '/_ruote/processes.json',
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(201)

    last_response.json_body['launched'].should match(/[0-9a-z\-]+/)

    sleep 0.4

    engine.processes.should_not be_empty
  end

  it 'should launch a valid process definition with fields (JSON)' do

    params = {
      :definition => %q{
        Ruote.process_definition :name => 'test' do
          echo '${f:foo}'
        end
      },
      :fields => { :foo => 'bar' }
    }

    post(
      '/_ruote/processes.json',
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(201)
    last_response.json_body['launched'].should match(/[0-9a-z\-]+/)

    sleep 0.5

    @tracer.to_s.should == 'bar'
  end

  it 'should launch a valid process definition (HTML)' do

    params = {
      :definition => %q{
        Ruote.process_definition :name => 'test' do
          wait '1m'
        end
      }
    }

    post '/_ruote/processes', params

    last_response.status.should == 201

    sleep 0.4

    engine.processes.should_not be_empty
  end

  it 'should launch a process definition with fields (HTML)' do

    params = {
      :definition => %{
        Ruote.process_definition :name => 'test' do
          echo '${f:foo}'
        end
      },
      :fields => '{ "foo": "bar" }'
    }

    post '/_ruote/processes', params

    last_response.status.should == 201

    sleep 0.5

    @tracer.to_s.should == 'bar'
  end

  it 'should correct for empty fields sent by browsers' do

    params = {
      :definition => %q{
        Ruote.process_definition :name => 'test' do
          wait '5m'
        end
      },
      :fields => ''
    }

    post '/_ruote/processes', params

    last_response.status.should == 201

    sleep 0.4

    engine.processes.should_not be_empty
  end

  it 'should return a 400 code when it fails to determine what to launch (JSON)' do

    params = { :definition => 'http://invalid.invalid' }

    post(
      '/_ruote/processes.json',
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(400)

    last_response.json_body.keys.should include('exception')
  end

  it 'should return a 400 code page when it fails to determine what to launch (HTML)' do

    params = { :definition => %q{http://invalid.invalid} }

    post '/_ruote/processes', params

    last_response.status.should be(400)

    last_response.should match(/failed to launch process/)
  end

end

describe 'DELETE /_ruote/processes/X-Y' do

  it_has_an_engine

  before(:each) do

    @wfid = launch_test_process do
      Ruote.process_definition :name => 'test' do
        sequence :on_cancel => 'bail_out' do
          echo 'done.'
          wait '1d'
        end

        define :name => 'bail_out' do
          echo 'bailout.'
        end
      end
    end
  end

  it 'should cancel processes (JSON)' do

    delete "/_ruote/processes/#{@wfid}.json"

    last_response.should be_ok

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == "done.\nbailout."
  end

  it 'should cancel processes (HMTL)' do

    delete "/_ruote/processes/#{@wfid}"

    last_response.should be_redirect
    last_response['Location'].should == '/_ruote/processes'

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == "done.\nbailout."
  end

  it 'should kill processes (JSON)' do

    delete "/_ruote/processes/#{@wfid}.json?_kill=1"

    last_response.should be_ok

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == 'done.'
  end

  it 'should kill processes (HTML)' do

    delete "/_ruote/processes/#{@wfid}?_kill=1"

    last_response.should be_redirect
    last_response['Location'].should == '/_ruote/processes'

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == 'done.'
  end
end

