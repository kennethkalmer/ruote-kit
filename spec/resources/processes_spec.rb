require 'spec_helper'

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
      'rel' => 'http://ruote.rubyforge.org/rels.html#process_errors' },
    { 'href' => "/_ruote/schedules/#{wfid}",
      'rel' => 'http://ruote.rubyforge.org/rels.html#process_schedules' }
  ]
end


describe 'GET /_ruote/processes' do

  before(:each) do

    prepare_engine_with_participants
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'without any running processes' do

    it 'should give no processes back (HTML)' do

      get '/_ruote/processes?limit=100&skip=0'

      last_response.status.should == 200

      last_response.should have_selector(
        'a', :content => 'as JSON')
      last_response.should have_selector(
        'a', :href => '/_ruote/processes.json?limit=100&skip=0')
    end

    it 'should give an empty array (JSON)' do

      get '/_ruote/processes.json'

      last_response.status.should == 200

      body = last_response.json_body
      body.should have_key('processes')

      body['processes'].should be_empty
    end
  end

  describe 'with running processes' do

    before(:each) do
      @wfid = launch_nada_process
    end

    it 'should give process information back (HTML)' do

      get '/_ruote/processes'

      last_response.status.should == 200
    end

    it 'should give process information back (JSON)' do

      get '/_ruote/processes.json'

      last_response.status.should == 200

      body = last_response.json_body

      body['processes'].should_not be_empty

      body['links'].should == [
        { 'href' => '/_ruote',
          'rel' => 'http://ruote.rubyforge.org/rels.html#root' },
        { 'href' => '/_ruote/processes',
          'rel' => 'http://ruote.rubyforge.org/rels.html#processes' },
        { 'href' => '/_ruote/workitems',
          'rel' => 'http://ruote.rubyforge.org/rels.html#workitems' },
        { 'href' => '/_ruote/errors',
          'rel' => 'http://ruote.rubyforge.org/rels.html#errors' },
        { 'href' => '/_ruote/participants',
          'rel' => 'http://ruote.rubyforge.org/rels.html#participants' },
        { 'href' => '/_ruote/schedules',
          'rel' => 'http://ruote.rubyforge.org/rels.html#schedules' },
        { 'href' => '/_ruote/history',
          'rel' => 'http://ruote.rubyforge.org/rels.html#history' },
        { 'href' => '/_ruote/processes',
          'rel' => 'self' },
        { 'href' => '/_ruote/processes',
          'rel' => 'all' },
        { 'href' => '/_ruote/processes?limit=100&skip=0',
          'rel' => 'first' },
        { 'href' => '/_ruote/processes?limit=100&skip=0',
          'rel' => 'last' },
        { 'href' => '/_ruote/processes?limit=100&skip=0',
          'rel' => 'previous' },
        { 'href' => '/_ruote/processes?limit=100&skip=0',
          'rel' => 'next' } ]

      body['processes'].first['links'].should == process_links(@wfid)
    end
  end
end

describe 'GET /_ruote/processes/wfid' do

  before(:each) do

    prepare_engine_with_participants
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'with a running process' do

    before(:each) do

      @wfid = launch_nada_process
    end

    it 'should give process information back (HTML)' do

      get "/_ruote/processes/#{@wfid}"

      last_response.status.should == 200

      last_response.should have_selector(
        'a[rel="http://ruote.rubyforge.org/rels.html#process_schedules"]')
    end

    it 'should give process information back (JSON)' do

      get "/_ruote/processes/#{@wfid}.json"

      last_response.status.should == 200

      body = last_response.json_body

      body.should have_key('process')

      body['process']['links'].should == process_links(@wfid)
    end
  end

  describe 'without a running process' do

    it 'should 404 correctly (HTML)' do

      get '/_ruote/processes/foo'

      last_response.status.should == 404

      last_response.should match(/resource not found/)
    end

    it 'should 404 correctly (JSON)' do

      get '/_ruote/processes/foo.json'

      last_response.status.should == 404

      last_response.json_body.keys.should include('http_error')

      last_response.json_body['http_error'].should == {
        'code' => 404, 'message' => 'resource not found', 'cause' => ''
      }
    end
  end
end

describe 'GET /_ruote/processes/new' do

  before(:each) do

    prepare_engine
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  it 'should return a launch form' do

    get '/_ruote/processes/new'

    last_response.status.should == 200

    last_response.should_not have_selector('a', :content => 'as JSON')
  end
end

describe 'POST /_ruote/processes' do

  before(:each) do

    prepare_engine
  end

  after(:each) do

    shutdown_and_purge_engine
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

    last_response.status.should == 201

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

    last_response.status.should == 201
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

  it 'should 400 code when it fails to determine what to launch (JSON)' do

    params = { :definition => 'http://invalid.invalid' }

    post(
      '/_ruote/processes.json',
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should == 400
    last_response.json_body.keys.should include('http_error')
  end

  it 'should 400 when it fails to determine what to launch (HTML)' do

    params = { :definition => %q{http://invalid.invalid} }

    post '/_ruote/processes', params

    last_response.status.should == 400
    last_response.should match(/bad request/)
  end

end

describe 'DELETE /_ruote/processes/wfid' do

  before(:each) do

    prepare_engine
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  before(:each) do

    @wfid = RuoteKit.engine.launch(Ruote.process_definition do
      sequence :on_cancel => 'bail_out' do
        echo 'in'
        wait '1d'
        echo 'done.'
      end

      define :name => 'bail_out' do
        echo 'bailout.'
      end
    end)

    RuoteKit.engine.wait_for(3)
  end

  it 'should cancel processes (JSON)' do

    delete "/_ruote/processes/#{@wfid}.json"

    last_response.status.should == 200

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == "in\nbailout."
  end

  it 'should cancel processes (HMTL)' do

    delete "/_ruote/processes/#{@wfid}"

    last_response.should be_redirect
    last_response['Location'].should == 'http://example.org/_ruote/processes'

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == "in\nbailout."
  end

  it 'should kill processes (JSON)' do

    delete "/_ruote/processes/#{@wfid}.json?_kill=1"

    last_response.status.should == 200

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == 'in'
  end

  it 'should kill processes (HTML)' do

    delete "/_ruote/processes/#{@wfid}?_kill=1"

    last_response.should be_redirect
    last_response['Location'].should == 'http://example.org/_ruote/processes'

    wait_for(@wfid)

    engine.process(@wfid).should be_nil

    @tracer.to_s.should == 'in'
  end
end

