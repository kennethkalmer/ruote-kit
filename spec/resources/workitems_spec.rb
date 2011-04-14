require 'spec_helper'

def workitem_count(from, to, of)
  [
    from, 'to', to, 'of', of, 'workitems'
  ].collect { |e|
    e.to_s
  }.join("\n          ")
end


describe 'GET /_ruote/workitems' do

  before(:each) do

    prepare_engine
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'without any workitems' do

    it 'should report no workitems (HTML)' do

      get '/_ruote/workitems'

      last_response.should be_ok

      last_response.should match(workitem_count(0, 0, 0))
    end

    it 'should report no workitems (JSON)' do

      get '/_ruote/workitems.json'

      last_response.should be_ok
      json = last_response.json_body

      json.should have_key('workitems')
      json['workitems'].should be_empty
    end
  end

  describe 'with workitems' do

    before(:each) do

      register_participants

      @wfid = RuoteKit.engine.launch(Ruote.process_definition do
        sequence do
          nada :activity => 'Work your magic'
        end
      end)

      RuoteKit.engine.wait_for(:nada)
      RuoteKit.engine.wait_for(1)
    end

    it 'should have a list of workitems (HTML)' do

      get '/_ruote/workitems'

      last_response.should match(workitem_count(1, 1, 1))
    end

    it 'should have a list of workitems (JSON)' do

      get '/_ruote/workitems.json'

      last_response.should be_ok
      json = last_response.json_body

      json['workitems'].size.should == 1

      wi = json['workitems'][0]

      wi.keys.should include('fei', 'participant_name', 'fields')
      wi['wfid'].should == @wfid
      wi['participant_name'].should == 'nada'
      wi['fields']['params']['activity'].should == 'Work your magic'
    end
  end
end

describe 'GET /_ruote/workitems/wfid' do

  before(:each) do

    prepare_engine
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'with workitems' do

    before(:each) do

      register_participants

      @wfid = RuoteKit.engine.launch(Ruote.process_definition do
        concurrence do
          nada :activity => 'This'
          nada :activity => 'Or that'
        end
      end)

      RuoteKit.engine.wait_for(:nada)
      RuoteKit.engine.wait_for(1)
    end

    it 'should list the workitems (HTML)' do

      get "/_ruote/workitems/#{@wfid}"

      last_response.should be_ok

      last_response.should have_selector(
        'div#pagination', :content => '2 workitems')
    end

    it 'should list the workitems (JSON)' do

      get "/_ruote/workitems/#{@wfid}.json"

      last_response.should be_ok

      json = last_response.json_body

      json.should have_key('workitems')
      json['workitems'].should_not be_empty
    end
  end

  describe 'without workitems' do

    it 'should report no workitems (HTML)' do

      get '/_ruote/workitems/foo'

      last_response.should be_ok

      last_response.should have_selector(
        'div#pagination', :content => '0 workitems')
    end

    it 'should report an empty list (JSON)' do

      get '/_ruote/workitems/foo.json'

      last_response.should be_ok

      json = last_response.json_body

      json.should have_key('workitems')
      json['workitems'].should be_empty
    end
  end
end

describe 'GET /_ruote/workitems/expid!subid!wfid' do

  before(:each) do

    prepare_engine_with_participants
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'with a workitem' do

    before(:each) do

      @wfid = RuoteKit.engine.launch(
        Ruote.process_definition(:name => 'x', :rev => 'y') do
          sequence do
            nada :activity => 'Work your magic'
          end
        end)

      RuoteKit.engine.wait_for(:nada)

      @fei = engine.process(@wfid).expressions.last.fei
    end

    it 'should return it (HTML)' do

      get "/_ruote/workitems/#{@fei.sid}"

      last_response.should be_ok
    end

    it 'should return it (JSON)' do

      get "/_ruote/workitems/#{@fei.sid}.json"

      last_response.should be_ok
    end

    it 'should provide a workitem with the correct links (JSON)' do

      get "/_ruote/workitems/#{@fei.sid}.json"

      last_response.json_body['workitem']['links'].collect { |li|
        li['rel']
      }.should == %w[
        self
        http://ruote.rubyforge.org/rels.html#process
        http://ruote.rubyforge.org/rels.html#process_expressions
        http://ruote.rubyforge.org/rels.html#process_errors
      ]
    end

    it 'should include an etag header (HTML)' do

      get "/_ruote/workitems/#{@fei.sid}"

      last_response.headers.should include('ETag')
      last_response.headers['ETag'].should == "\"#{find_workitem(@wfid, @nada_exp_id).to_h['_rev'].to_s}\""
    end

    it 'should include an etag header (JSON)' do

      get "/_ruote/workitems/#{@fei.sid}.json"

      last_response.headers.should include('ETag')
      last_response.headers['ETag'].should == "\"#{find_workitem(@wfid, @nada_exp_id).to_h['_rev'].to_s}\""
    end

    it 'should include a wf_name and a wf_revision (JSON)' do

      get "/_ruote/workitems/#{@fei.sid}.json"

      last_response.json_body['workitem']['wf_name'].should_not == nil
      last_response.json_body['workitem']['wf_revision'].should_not == nil
    end
  end

  describe 'without a workitem' do

    it 'should return a 404 (HTML)' do

      get '/_ruote/workitems/foo/bar'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it 'should return a 404 (JSON)' do

      get '/_ruote/workitems/foo/bar.json'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe 'PUT /_ruote/workitems/fei' do

  before(:each) do

    prepare_engine_with_participants

    @wfid = RuoteKit.engine.launch(Ruote.process_definition do
      sequence do
        nada :activity => 'Work your magic'
        echo '${f:foo}'
      end
    end)

    RuoteKit.engine.wait_for(:nada)

    @fei = engine.process(@wfid).expressions.last.fei

    @fields = {
      'params' => { 'activity' => 'Work your magic' }, 'foo' => 'bar'
    }
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  it 'should update the workitem fields (HTML)' do

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
      :fields => Rufus::Json.encode(@fields))

    last_response.should be_redirect

    last_response['Location'].should ==
      "http://example.org/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}"

    find_workitem(@wfid, @nada_exp_id).fields.should == @fields

    sleep 0.4

    @tracer.to_s.should == ''
  end

  it 'should update the workitem fields (JSON)' do

    params = { 'fields' => @fields }

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.should be_ok

    find_workitem(@wfid, @nada_exp_id).fields.should == @fields

    sleep 0.4

    @tracer.to_s.should == ''
  end

  it 'should update the fields when passed {"workitem":...} (JSON)' do

    params = { 'workitem' => { 'fields' => @fields } }

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.should be_ok

    find_workitem(@wfid, @nada_exp_id).fields.should == @fields
  end

  it 'should reply to the engine (HTML)' do

    fields = Rufus::Json.encode(@fields)

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
      :fields => fields,
      :_proceed => '1')

    last_response.should be_redirect
    last_response['Location'].should == "http://example.org/_ruote/workitems/#{@wfid}"

    #engine.context[:s_logger].wait_for([
    #  [ :processes, :terminated, { :wfid => @wfid } ],
    #  [ :errors, nil, { :wfid => @wfid } ]
    #])
    sleep 0.5

    @tracer.to_s.should == 'bar'
  end

  it 'should reply to the engine (JSON)' do

    params = { 'fields' => @fields, '_proceed' => '1' }

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      Rufus::Json.encode(params),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.should be_ok

    #engine.context[:s_logger].wait_for([
    #  [ :processes, :terminated, { :wfid => @wfid } ],
    #  [ :errors, nil, { :wfid => @wfid } ]
    #])
    sleep 0.5

    @tracer.to_s.should == 'bar'
  end

  it 'should 400 when passed bogus JSON fields (HTML)' do

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      :fields => '{"bogus"}')

    last_response.status.should be(400)
  end

  it 'should 400 when passed bogus JSON fields (JSON)' do

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      "{'bogus'}",
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(400)
  end

  it 'should 412 if the etags do not match (HTML)' do

    workitem = find_workitem(@wfid, @nada_exp_id)
    old_rev  = workitem.to_h['_rev']

    workitem.fields = {'baz' => 'bar'}.merge!(@fields)
    RuoteKit.engine.storage_participant.update(workitem)

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
      { :fields => Rufus::Json.encode(@fields) },
      { 'HTTP_IF_MATCH' => ('"%s"' % old_rev) }
    )

    last_response.status.should be(412)
  end

  it 'should 412 if the etags do not match (JSON)' do

    workitem = find_workitem(@wfid, @nada_exp_id)

    old_rev = workitem.to_h['_rev']

    workitem.fields = {'baz' => 'bar'}.merge!(@fields)
    RuoteKit.engine.storage_participant.update(workitem)

    params = { 'workitem' => { 'fields' => @fields } }

    put(
      "/_ruote/workitems/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
      Rufus::Json.encode(params),
      {
        'CONTENT_TYPE'  => 'application/json',
        'HTTP_IF_MATCH' => ('"%s"' % old_rev)
      }
    )

    last_response.status.should be(412)
  end
end

describe 'Filtering workitems' do

  before(:each) do

    prepare_engine_with_participants

    @wfid = RuoteKit.engine.launch(Ruote.process_definition do
      set 'foo' => 'bar'
      concurrence do
        sequence do
          set 'wands' => 101
          set 'hinkypinky' => 'honkytonky'
          jack :activity => 'Fetch a pale'
        end
        sequence do
          set 'hinkypinky' => 'honkytonky'
          jill :activity => 'Chase Jack'
        end
        well :activity => 'Ready water'
      end
    end)

    RuoteKit.engine.wait_for(:jack)
    RuoteKit.engine.wait_for(1)
  end

  after(:each) do

    shutdown_and_purge_engine
  end

  describe 'on participants' do

    it 'should narrow results down to a single participant (JSON)' do

      get '/_ruote/workitems.json', :participant => 'jack'

      last_response.should be_ok

      last_response.json_body['workitems'].size.should == 1
    end

    it 'should narrow results down to a single participant (HTML)' do

      get '/_ruote/workitems', :participant => 'jack'

      last_response.should be_ok

      last_response.should match(workitem_count(1, 3, 3))
    end

  end

  describe 'on field values' do

    it 'should find workitems with fields set to a given value (JSON)' do

      get '/_ruote/workitems.json', :hinkypinky => 'honkytonky'

      last_response.should be_ok

      last_response.json_body['workitems'].size.should == 2
    end

    it 'should find workitems with fields set to a given value (HTML)' do

      get '/_ruote/workitems', :hinkypinky => 'honkytonky'

      last_response.should be_ok
    end

    it 'should respect JSON encoded filter vars (JSON)' do

      get '/_ruote/workitems.json', :wands => 101

      last_response.should be_ok

      last_response.json_body['workitems'].size.should == 1
    end

    it 'should respect JSON encoded filter vars (HTML)' do

      get '/_ruote/workitems', :wands => 101

      last_response.should be_ok
    end

    it "should combine search criteria by 'and' (JSON)" do

      get '/_ruote/workitems.json', :hinkypinky => 'honkytonky', :wands => 101

      last_response.should be_ok

      last_response.json_body['workitems'].size.should == 1
    end

    it "should combine search criteria by 'and' (HMTL)" do

      get '/_ruote/workitems', :hinkypinky => 'honkytonky', :wands => 101

      last_response.should be_ok
    end
  end
end

