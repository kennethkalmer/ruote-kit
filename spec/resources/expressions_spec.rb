
require File.join(File.dirname(__FILE__), '/../spec_helper')

undef :context if defined?(context)


describe 'GET /_ruote/expressions' do

  it_has_an_engine

  it 'should 404 (HTML)' do

    get '/_ruote/expressions'

    last_response.status.should be(404)
  end
end

describe 'GET /_ruote/expressions/wfid' do

  it_has_an_engine

  describe 'with running processes' do

    before(:each) do
      @wfid = launch_test_process
    end

    it 'should render the expressions (HTML)' do

      get "/_ruote/expressions/#{@wfid}"

      last_response.should be_ok
    end

    it 'should render the expressions (JSON)' do

      get "/_ruote/expressions/#{@wfid}.json"

      last_response.should be_ok

      last_response.json_body['expressions'].first.keys.sort.should == %w[
        class fei links name parent
      ]
    end
  end

  describe 'without running processes' do

    it 'should 404 correctly (HTML)' do

      get "/_ruote/expressions/foo"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it 'should 404 correctly (JSON)' do

      get '/_ruote/expressions/foo.json'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe 'GET /_ruote/expressions/fei' do

  it_has_an_engine

  describe 'with running processes' do

    before(:each) do

      @wfid = launch_test_process
      process = engine.process(@wfid)
      @nada_exp_id = process.expressions.last.fei.expid
    end

    it 'should render the expression (HTML)' do

      get "/_ruote/expressions/#{@nada_exp_id}!!#{@wfid}"

      last_response.should be_ok
    end

    it 'should render the expression (JSON)' do

      get "/_ruote/expressions/#{@nada_exp_id}!!#{@wfid}.json"

      last_response.should be_ok

      #puts Rufus::Json.pretty_encode(last_response.json_body)

      last_response.json_body['expression']['links'].size.should be(4)

      last_response.json_body['expression'].keys.sort.should == %w[
        applied_workitem class fei links name original_tree parent
        timeout_schedule_id tree variables
      ]
    end
  end

  describe 'without running processes' do

    it 'should 404 correctly (HTML)' do

      get '/workitems/foo/bar'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it 'should 404 correctly (JSON)' do

      get '/workitems/foo/bar.json'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end

  describe 'with an expression that has a schedule' do

    before(:each) do

      @wfid = RuoteKit.engine.launch(Ruote.define do
        alpha :timeout => '2y'
      end)

      RuoteKit.engine.wait_for(:alpha)
    end

    it 'should render the expression (HTML)' do

      get "/_ruote/expressions/0_0!!#{@wfid}"

      last_response.status.should be(200)

      last_response.should have_selector(
        'table.details tr td', :content => 'timeout')
    end

    it 'should render the expression (JSON)' do

      get "/_ruote/expressions/0_0!!#{@wfid}.json"

      last_response.status.should be(200)

      #puts Rufus::Json.pretty_encode(last_response.json_body)

      last_response.json_body['expression'].keys.should include(
        'timeout_schedule_id')
    end
  end
end

describe 'DELETE /_ruote/expressions/fei' do

  it_has_an_engine

  describe 'with running processes' do

    before(:each) do

      @wfid = launch_test_process do
        Ruote.process_definition :name => 'delete' do
          sequence do
            wait '1d', :on_cancel => 'bail_out'
            echo 'done'
          end

          define 'bail_out' do
            sequence do
              echo 'bailed'
            end
          end
        end
      end

      wait_exp = engine.process(@wfid).expressions.last
      @expid = "0_1_0" #wait_exp.fei.expid
    end

    it 'should cancel the expressions (HTML)' do

      delete "/_ruote/expressions/#{@expid}!!#{@wfid}"

      last_response.should be_redirect
      last_response['Location'].should == "/_ruote/expressions/#{@wfid}"

      #sleep 0.4
      wait_for(@wfid)

      @tracer.to_s.should == "bailed\ndone"
    end

    it 'should cancel the expressions (JSON)' do

      delete "/_ruote/expressions/#{@expid}!!#{@wfid}.json"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      #sleep 0.4
      wait_for(@wfid)

      @tracer.to_s.should == "bailed\ndone"
    end

    it 'should kill the expression (HTML)' do

      delete "/_ruote/expressions/#{@expid}!!#{@wfid}?_kill=1"

      last_response.should be_redirect
      last_response['Location'].should == "/_ruote/expressions/#{@wfid}"

      #sleep 0.4
      wait_for(@wfid)

      @tracer.to_s.should == 'done'
    end

    it 'should kill the expression (JSON)' do

      delete "/_ruote/expressions/#{@expid}!!#{@wfid}.json?_kill=1"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      #sleep 0.4
      wait_for(@wfid)

      @tracer.to_s.should == 'done'
    end
  end

  describe 'without running processes' do

    it 'should 404 correctly (HTML)' do

      delete '/_ruote/expressions/foo/bar'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it 'should 404 correctly (JSON)' do

      delete '/_ruote/expressions/foo/bar.json'

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe 'PUT /_ruote/expressions/fei' do

  it_has_an_engine

  before(:each) do

    @wfid = launch_test_process do
      Ruote.process_definition do
        alpha
      end
    end

    @exp = RuoteKit.engine.process(@wfid).expressions.find { |e|
      e.fei.expid == '0_0'
    }
  end

  it 'should re-apply (HTML)' do

    at0 = RuoteKit.engine.storage_participant.first.dispatched_at

    put(
      "/_ruote/expressions/#{@exp.fei.sid}",
      :fields => '{}')

    last_response.status.should be(302)
    last_response.location.should == "/_ruote/expressions/#{@wfid}"

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    at1 = RuoteKit.engine.storage_participant.first.dispatched_at

    at1.should_not == at0
  end

  it 'should re-apply (JSON)' do

    #RuoteKit.engine.noisy = true

    at0 = RuoteKit.engine.storage_participant.first.dispatched_at

    put(
      "/_ruote/expressions/#{@exp.fei.sid}.json",
      Rufus::Json.encode({}),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(200)

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    at1 = RuoteKit.engine.storage_participant.first.dispatched_at

    at1.should_not == at0
  end

  it 'should re-apply with different fields (HTML)' do

    wi = RuoteKit.engine.storage_participant.first
    wi.fields['car'].should be(nil)

    put(
      "/_ruote/expressions/#{@exp.fei.sid}",
      :fields => '{"car":"daimler-benz"}')

    last_response.status.should be(302)
    last_response.location.should == "/_ruote/expressions/#{@wfid}"

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    wi = RuoteKit.engine.storage_participant.first

    wi.fields['car'].should == 'daimler-benz'
  end

  it 'should re-apply with different fields (JSON)' do

    wi = RuoteKit.engine.storage_participant.first
    wi.fields['car'].should be(nil)

    put(
      "/_ruote/expressions/#{@exp.fei.sid}.json",
      Rufus::Json.encode({ 'fields' => { 'car' => 'bentley' } }),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(200)

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    wi = RuoteKit.engine.storage_participant.first

    wi.fields['car'].should == 'bentley'
  end

  it 'should re-apply when passed {"expression":{"fields":...}} (JSON)' do

    exp = { 'expression' => { 'fields' => { 'car' => 'BMW' } } }

    put(
      "/_ruote/expressions/#{@exp.fei.sid}.json",
      Rufus::Json.encode(exp),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(200)

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    wi = RuoteKit.engine.storage_participant.first

    wi.fields['car'].should == 'BMW'
  end

  it 'should re-apply with a different tree (HTML)' do

    put(
      "/_ruote/expressions/#{@exp.fei.sid}",
      :tree => '["charly", {}, []]')

    last_response.status.should be(302)
    last_response.location.should == "/_ruote/expressions/#{@wfid}"

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    wi = RuoteKit.engine.storage_participant.first

    wi.participant_name.should == 'charly'

    RuoteKit.engine.process(@wfid).current_tree.should == [ 'define', {}, [
      [ 'participant', { '_triggered' => 'on_re_apply', 'ref' => 'charly' }, [] ] ] ]
  end

  it 'should re-apply with a different tree (JSON)' do

    wi = RuoteKit.engine.storage_participant.first
    wi.participant_name.should == 'alpha'

    put(
      "/_ruote/expressions/#{@exp.fei.sid}.json",
      Rufus::Json.encode({ 'tree' => [ 'bravo', {}, [] ] }),
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(200)

    #RuoteKit.engine.wait_for(:alpha)
    sleep 0.500

    wi = RuoteKit.engine.storage_participant.first

    wi.participant_name.should == 'bravo'

    RuoteKit.engine.process(@wfid).current_tree.should == [ 'define', {}, [
      [ 'participant', { '_triggered' => 'on_re_apply', 'ref' => 'bravo' }, [] ] ] ]
  end

  it 'should 400 when passed bogus JSON (HTML)' do

    put(
      "/_ruote/expressions/#{@exp.fei.sid}",
      :fields => "{bogus}")

    last_response.status.should be(400)
  end

  it 'should 400 when passed bogus JSON (JSON)' do

    put(
      "/_ruote/expressions/#{@exp.fei.sid}.json",
      '{"fields":{bogus}}',
      { 'CONTENT_TYPE' => 'application/json' })

    last_response.status.should be(400)
    last_response.json_body['http_error']['code'].should == 400
    last_response.json_body['http_error']['message'].should == 'bad request'
  end
end

