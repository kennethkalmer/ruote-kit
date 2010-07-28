
require File.join( File.dirname( __FILE__ ), '/../spec_helper' )

undef :context if defined?( context )


describe 'GET /_ruote/workitems' do

  it_has_an_engine

  describe 'without any workitems' do

    it 'should report no workitems (HTML)' do

      get '/_ruote/workitems'

      last_response.should be_ok

      last_response.should have_selector(
        'div.warn p', :content => 'No workitems are currently available' )
    end

    it 'should report no workitems (JSON)' do

      get '/_ruote/workitems.json'

      last_response.should be_ok
      json = last_response.json_body

      json.should have_key( 'workitems' )
      json['workitems'].should be_empty
    end
  end

  describe 'with workitems' do

    before( :each ) do

      @wfid = launch_test_process do
        Ruote.process_definition :name => 'test' do
          sequence do
            nada :activity => 'Work your magic'
          end
        end
      end
    end

    it 'should have a list of workitems (HTML)' do

      get '/_ruote/workitems'

      last_response.should be_ok
      last_response.should match( /1 workitem available/ )
    end

    it 'should have a list of workitems (JSON)' do

      get '/_ruote/workitems.json'

      last_response.should be_ok
      json = last_response.json_body

      json['workitems'].size.should be( 1 )

      wi = json['workitems'][0]

      wi.keys.should include( 'fei', 'participant_name', 'fields' )
      wi['fei']['wfid'].should == @wfid
      wi['participant_name'].should == 'nada'
      wi['fields']['params']['activity'].should == 'Work your magic'
    end
  end
end

describe 'GET /_ruote/workitems/wfid' do

  it_has_an_engine

  describe 'with workitems' do

    before( :each ) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          concurrence do
            nada :activity => 'This'
            nada :activity => 'Or that'
          end
        end
      end
    end

    it 'should list the workitems (HTML)' do

      get "/_ruote/workitems/#{@wfid}"

      last_response.should be_ok
      last_response.should match( /2 workitems available for #{@wfid}/ )
    end

    it 'should list the workitems (JSON)' do

      get "/_ruote/workitems/#{@wfid}.json"

      last_response.should be_ok

      json = last_response.json_body

      json.should have_key( 'workitems' )
      json['workitems'].should_not be_empty
    end
  end

  describe 'without workitems' do

    it 'should report no workitems (HTML)' do

      get '/_ruote/workitems/foo'

      last_response.should be_ok
      last_response.should match( /No workitems are currently available for foo/ )
    end

    it 'should report an empty list (JSON)' do

      get '/_ruote/workitems/foo.json'

      last_response.should be_ok

      json = last_response.json_body

      json.should have_key( 'workitems' )
      json['workitems'].should be_empty
    end
  end
end

describe 'GET /_ruote/workitems/wfid/expid' do

  it_has_an_engine

  describe 'with a workitem' do

    before( :each ) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          sequence do
            nada :activity => 'Work your magic'
          end
        end
      end

      process = engine.process( @wfid )
      @nada_exp_id = '0_0_0' #process.expressions.last.fei.expid

      @nada_exp_id.should_not be_nil
    end

    it 'should return it (HTML)' do

      get "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}"

      last_response.should be_ok
    end

    it 'should return it (JSON)' do

      get "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}.json"

      last_response.should be_ok
    end
  end

  describe 'without a workitem' do

    it 'should return a 404 (HTML)' do
      get '/_ruote/workitems/foo/bar'

      last_response.should_not be_ok
      last_response.status.should be( 404 )
    end

    it 'should return a 404 (JSON)' do
      get '/_ruote/workitems/foo/bar.json'

      last_response.should_not be_ok
      last_response.status.should be( 404 )
    end
  end
end

describe 'PUT /_ruote/workitems/X-Y' do

  it_has_an_engine

  before( :each ) do

    @wfid = launch_test_process do
      Ruote.process_definition :name => 'foo' do
        sequence do
          nada :activity => 'Work your magic'
          echo '${f:foo}'
        end
      end
    end

    process = engine.process( @wfid )
    @nada_exp_id = '0_0_0' #process.expressions.last.fei.expid

    @nada_exp_id.should_not be_nil

    @fields = {
      'params' => { 'activity' => 'Work your magic' }, 'foo' => 'bar'
    }
  end

  it 'should update the workitem fields (HTML)' do

    put(
      "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}",
      :fields => Rufus::Json.encode( @fields ) )

    last_response.should be_redirect

    last_response['Location'].should ==
      "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}"

    find_workitem( @wfid, @nada_exp_id ).fields.should == @fields

    sleep 0.4

    @tracer.to_s.should == ''
  end

  it 'should update the workitem fields (JSON)' do

    params = { 'fields' => @fields }

    put(
      "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}.json",
      Rufus::Json.encode( params ),
      { 'CONTENT_TYPE' => 'application/json' } )

    last_response.should be_ok

    find_workitem( @wfid, @nada_exp_id ).fields.should == @fields

    sleep 0.4

    @tracer.to_s.should == ''
  end

  it 'should reply to the engine (HTML)' do

    fields = Rufus::Json.encode( @fields )

    put(
      "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}",
      :fields => fields,
      :_proceed => '1' )

    last_response.should be_redirect
    last_response['Location'].should == "/_ruote/workitems/#{@wfid}"

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
      "/_ruote/workitems/#{@nada_exp_id}!!#{@wfid}.json",
      Rufus::Json.encode( params ),
      { 'CONTENT_TYPE' => 'application/json' } )

    last_response.should be_ok

    #engine.context[:s_logger].wait_for([
    #  [ :processes, :terminated, { :wfid => @wfid } ],
    #  [ :errors, nil, { :wfid => @wfid } ]
    #])
    sleep 0.5

    @tracer.to_s.should == 'bar'
  end
end

describe 'Filtering workitems' do

  it_has_an_engine

  before( :each ) do

    @wfid = launch_test_process do
      Ruote.process_definition :name => 'test' do
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
      end
    end
  end

  describe 'on participants' do

    it 'should narrow results down to a single participant (JSON)' do

      get '/_ruote/workitems.json', :participant => 'jack'

      last_response.should be_ok

      last_response.json_body['workitems'].size.should be( 1 )
    end

    it 'should narrow results down to a single participant (HTML)' do

      get '/_ruote/workitems', :participant => 'jack'

      last_response.should be_ok

      last_response.should have_selector(
        'div.notice p', :content => '1 workitem available' )
      #last_response.should have_selector(
      #  'div.notice p', :content => 'Filtered for participant(s): jack' )
    end

  end

  describe 'on field values' do

    it 'should find worktitems with fields set to a given value (JSON)' do

      get '/_ruote/workitems.json', :hinkypinky => 'honkytonky'

      last_response.should be_ok

      last_response.json_body['workitems'].size.should be( 2 )
    end

    it 'should find worktitems with fields set to a given value (HTML)' do

      get '/_ruote/workitems', :hinkypinky => 'honkytonky'

      last_response.should be_ok
    end

    it 'should respect JSON encoded filter vars (JSON)' do

      get '/_ruote/workitems.json', :wands => 101

      last_response.should be_ok

      last_response.json_body['workitems'].size.should be( 1 )
    end

    it 'should respect JSON encoded filter vars (HTML)' do

      get '/_ruote/workitems', :wands => 101

      last_response.should be_ok
    end

    it "should combine search criteria by 'and' (JSON)" do

      get '/_ruote/workitems.json', :hinkypinky => 'honkytonky', :wands => 101

      last_response.should be_ok

      last_response.json_body['workitems'].size.should be( 1 )
    end

    it "should combine search criteria by 'and' (HMTL)" do

      get '/_ruote/workitems', :hinkypinky => 'honkytonky', :wands => 101

      last_response.should be_ok
    end
  end
end

