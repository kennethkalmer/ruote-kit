
require 'spec_helper'


describe '/_ruote/expressions' do

  before(:each) do
    prepare_engine_with_participants
  end
  after(:each) do
    shutdown_and_purge_engine
  end

  describe 'GET /_ruote/expressions' do

    it 'goes 404 (HTML)' do

      get '/_ruote/expressions'

      last_response.status.should be(404)
    end
  end

  describe 'GET /_ruote/expressions/:wfid' do

    context 'with running processes' do

      before(:each) do
        @wfid = launch_nada_process
      end

      it 'renders the expressions (HTML)' do

        get "/_ruote/expressions/#{@wfid}"

        last_response.should be_ok
      end

      it 'renders the expressions (JSON)' do

        get "/_ruote/expressions/#{@wfid}.json"

        last_response.should be_ok

        last_response.json_body['expressions'].first.keys.sort.should == %w[
          class fei links name parent state
        ]
      end
    end

    context 'without running processes' do

      it 'goes 404 correctly (HTML)' do

        get "/_ruote/expressions/foo"

        last_response.should_not be_ok
        last_response.status.should be(404)
      end

      it 'goes 404 correctly (JSON)' do

        get '/_ruote/expressions/foo.json'

        last_response.should_not be_ok
        last_response.status.should be(404)
      end
    end
  end

  describe 'GET /_ruote/expressions/:fei' do

    context 'with running processes' do

      before(:each) do

        @wfid = launch_nada_process
        @nada_fexp = RuoteKit.engine.process(@wfid).expressions.last
        @nada_fei = @nada_fexp.fei
      end

      it 'renders the expression (HTML)' do

        get "/_ruote/expressions/#{@nada_fei.sid}"

        last_response.status.should ==
          200
        last_response.should have_selector(
          'input[name="_method"][type="hidden"][value="DELETE"]')
        last_response.should have_selector(
          'input[type="submit"][value="pause"]')
      end

      it 'renders the expression (JSON)' do

        get "/_ruote/expressions/#{@nada_fei.sid}.json"

        last_response.should be_ok

        #puts Rufus::Json.pretty_encode(last_response.json_body)

        last_response.json_body['expression']['links'].size.should == 4

        last_response.json_body['expression'].keys.sort.should == %w[
          applied_workitem class fei links name original_tree parent state
          timeout_schedule_id tree variables
        ]
      end

      it 'includes an etag header (HTML)' do

        get "/_ruote/expressions/#{@nada_fei.sid}"

        last_response.headers.should include('ETag')

        last_response.headers['ETag'].should ==
          "\"#{@nada_fexp.to_h['_rev'].to_s}\""
      end

      it 'includes an etag header (JSON)' do

        get "/_ruote/expressions/#{@nada_fei.sid}.json"

        last_response.headers.should include('ETag')

        last_response.headers['ETag'].should ==
          "\"#{@nada_fexp.to_h['_rev'].to_s}\""
      end
    end

    context 'without running processes' do

      it 'goes 404 correctly (HTML)' do

        get '/workitems/foo/bar'

        last_response.should_not be_ok
        last_response.status.should be(404)
      end

      it 'goes 404 correctly (JSON)' do

        get '/workitems/foo/bar.json'

        last_response.should_not be_ok
        last_response.status.should be(404)
      end
    end

    context 'with an expression that has a schedule' do

      before(:each) do

        @wfid = RuoteKit.engine.launch(Ruote.define do
          alpha :timeout => '2y'
        end)

        RuoteKit.engine.wait_for(:alpha)

        @fei = RuoteKit.engine.process(@wfid).expressions.last.fei
      end

      it 'renders the expression (HTML)' do

        get "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}"

        last_response.status.should be(200)

        last_response.should have_selector(
          'table.details tr td', :content => 'timeout')
      end

      it 'renders the expression (JSON)' do

        get "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json"

        last_response.status.should be(200)

        #puts Rufus::Json.pretty_encode(last_response.json_body)

        last_response.json_body['expression'].keys.should include(
          'timeout_schedule_id')
      end
    end
  end

  describe 'DELETE /_ruote/expressions/:fei' do

    context 'with running processes' do

      before(:each) do

        @wfid = RuoteKit.engine.launch(Ruote.process_definition do
          sequence do
            alfred :on_cancel => 'bail_out'
            echo 'done'
          end

          define 'bail_out' do
            echo 'bailed'
          end
        end)

        RuoteKit.engine.wait_for(:alfred)

        @fei = engine.process(@wfid).expressions.last.fei
      end

      it 'cancels the expressions (HTML)' do

        delete "/_ruote/expressions/#{@fei.sid}"

        last_response.should be_redirect
        last_response['Location'].should == "http://example.org/_ruote/expressions/#{@wfid}"

        wait_for(@wfid)

        @tracer.to_s.should == "bailed\ndone"
      end

      it 'cancels the expressions (JSON)' do

        delete "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json"

        last_response.should be_ok
        last_response.json_body['status'].should == 'ok'

        wait_for(@wfid)

        @tracer.to_s.should == "bailed\ndone"
      end

      it 'kills the expression (HTML)' do

        delete "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}?_kill=1"

        last_response.should be_redirect
        last_response['Location'].should == "http://example.org/_ruote/expressions/#{@wfid}"

        wait_for(@wfid)

        @tracer.to_s.should == 'done'
      end

      it 'kills the expression (JSON)' do

        delete "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json?_kill=1"

        last_response.should be_ok
        last_response.json_body['status'].should == 'ok'

        wait_for(@wfid)

        @tracer.to_s.should == 'done'
      end

      it 'goes 412 when the etags do not match (HTML)' do

        delete(
          "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
          nil,
          { 'HTTP_IF_MATCH' => '"foo"' }
        )

        last_response.status.should == 412
      end

      it 'goes 412 when the etags do not match (JSON)' do

        delete(
          "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
          nil,
          {
            'HTTP_IF_MATCH' => '"foo"',
            'CONTENT_TYPE'  => 'application/json',
          }
        )

        last_response.status.should == 412
      end

      it 'does not go 412 when the etags do match (HTML)' do

        exp = RuoteKit.engine.process(@wfid).expressions.find { |e|
          e.fei.expid == @fei.expid
        }

        delete(
          "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
          nil,
          { 'HTTP_IF_MATCH' => ('"%s"' % exp.to_h['_rev'] ) }
        )

        last_response.status.should_not == 412
      end

      it 'does not go 412 when the etags do match (JSON)' do

        exp = RuoteKit.engine.process(@wfid).expressions.find { |e|
          e.fei.expid == @fei.expid
        }

        delete(
          "/_ruote/expressions/#{@fei.expid}!#{@fei.subid}!#{@wfid}.json",
          nil,
          {
            'HTTP_IF_MATCH' => ('"%s"' % exp.to_h['_rev'] ),
            'CONTENT_TYPE'  => 'application/json',
          }
        )

        last_response.status.should_not == 412
      end
    end

    context 'without running processes' do

      it 'goes 404 correctly (HTML)' do

        delete '/_ruote/expressions/foo/bar'

        last_response.should_not be_ok
        last_response.status.should be(404)
      end

      it 'goes 404 correctly (JSON)' do

        delete '/_ruote/expressions/foo/bar.json'

        last_response.should_not be_ok
        last_response.status.should be(404)
      end
    end
  end

  describe 'PUT /_ruote/expressions/:fei' do

    before(:each) do

      @wfid = RuoteKit.engine.launch(

        Ruote.process_definition do
          alpha
        end
      )

      RuoteKit.engine.wait_for(:alpha)
      RuoteKit.engine.wait_for(1)

      @exp = RuoteKit.engine.process(@wfid).expressions.last
    end

    context 're_apply' do

      it 're-applies (HTML)' do

        at0 = RuoteKit.engine.storage_participant.first.dispatched_at

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :fields => '{}')

        last_response.status.should be(302)
        last_response.location.should == "http://example.org/_ruote/expressions/#{@wfid}"

        #RuoteKit.engine.wait_for(:alpha)
        sleep 0.500

        at1 = RuoteKit.engine.storage_participant.first.dispatched_at

        at1.should_not == at0
      end

      it 're-applies (JSON)' do

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

      it 're-applies with different fields (HTML)' do

        wi = RuoteKit.engine.storage_participant.first
        wi.fields['car'].should be(nil)

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :fields => '{"car":"daimler-benz"}')

        last_response.status.should be(302)
        last_response.location.should == "http://example.org/_ruote/expressions/#{@wfid}"

        #RuoteKit.engine.wait_for(:alpha)
        sleep 0.500

        wi = RuoteKit.engine.storage_participant.first

        wi.fields['car'].should == 'daimler-benz'
      end

      it 're-applies with different fields (JSON)' do

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

      it 're-applies when passed {"expression":{"fields":...}} (JSON)' do

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

      it 're-applies with a different tree (HTML)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :tree => '["charly", {}, []]')

        last_response.status.should be(302)
        last_response.location.should == "http://example.org/_ruote/expressions/#{@wfid}"

        #RuoteKit.engine.wait_for(:alpha)
        sleep 0.500

        wi = RuoteKit.engine.storage_participant.first

        wi.participant_name.should == 'charly'

        RuoteKit.engine.process(@wfid).current_tree.should == ['define', {}, [
          [ 'participant', { '_triggered' => 'on_re_apply', 'ref' => 'charly' }, [] ] ] ]
      end

      it 're-applies with a different tree (JSON)' do

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
    end

    context 'pausing and resuming' do

      it 'pauses the expression (branch) (HTML)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :state => 'paused')

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}"

        sleep 0.500

        exp = RuoteKit.engine.ps(@wfid).expressions.last

        exp.state.should == 'paused'
      end

      it 'pauses the expression (branch) (JSON)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}.json",
          '{"state":"paused"}',
          { 'CONTENT_TYPE' => 'application/json' })

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}.json"

        sleep 0.500

        exp = RuoteKit.engine.ps(@wfid).expressions.last

        exp.state.should == 'paused'
      end

      it 'resumes the expression (branch) (HTML)' do

        RuoteKit.engine.pause(@exp.fei)

        sleep 0.500

        RuoteKit.engine.ps(@wfid).expressions[-1].state.should == 'paused'

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :state => 'resuming')

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}"

        sleep 0.500

        RuoteKit.engine.ps(@wfid).expressions[-1].state.should == nil
      end

      it 'resumes the expression (branch) (JSON)' do

        RuoteKit.engine.pause(@exp.fei)

        sleep 0.500

        RuoteKit.engine.ps(@wfid).expressions[-1].state.should == 'paused'

        put(
          "/_ruote/expressions/#{@exp.fei.sid}.json",
          '{"state":"resuming"}',
          { 'CONTENT_TYPE' => 'application/json' })

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}.json"

        sleep 0.500

        RuoteKit.engine.ps(@wfid).expressions[-1].state.should == nil
      end
    end

    context 'pausing as a breakpoint' do

      before(:each) do

        @wfid = RuoteKit.engine.launch(Ruote.define do
          sequence do
            nada
          end
        end)

        RuoteKit.engine.wait_for(:nada)
        RuoteKit.engine.wait_for(1)

        @exp = RuoteKit.engine.ps(@wfid).expressions[-2]
      end

      it 'pauses the expression (breakpoint) (HTML)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :state => 'paused', :breakpoint => true)

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}"

        sleep 0.500

        states = RuoteKit.engine.ps(@wfid).expressions.collect { |fexp|
          [ fexp.fei.expid, fexp.state || 'running' ]
        }.join(' ')

        states.should == '0 running 0_0 paused 0_0_0 running'
      end

      it 'pauses the expression (breakpoint) (JSON)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          Rufus::Json.dump({ 'state' => 'paused', 'breakpoint' => true }),
          { 'CONTENT_TYPE' => 'application/json' })

        last_response.status.should ==
          302
        last_response.location.should ==
          "http://example.org/_ruote/expressions/#{@exp.fei.sid}.json"

        sleep 0.500

        states = RuoteKit.engine.ps(@wfid).expressions.collect { |fexp|
          [ fexp.fei.expid, fexp.state || 'running' ]
        }.join(' ')

        states.should == '0 running 0_0 paused 0_0_0 running'
      end
    end

    context 'broken JSON' do

      it 'goes 400 when passed broken JSON (HTML)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          :fields => "{broken}")

        last_response.status.should == 400
      end

      it 'goes 400 when passed broken JSON (JSON)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}.json",
          '{"fields":{broken}}',
          { 'CONTENT_TYPE' => 'application/json' })

        last_response.status.should be(400)
        last_response.json_body['http_error']['code'].should == 400
        last_response.json_body['http_error']['message'].should == 'bad request'
      end
    end

    context 'with etags' do

      it 'goes 412 when the etags do not match (HTML)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          { :fields => '{}' },
          { 'HTTP_IF_MATCH' => '"foo"' }
        )

        last_response.status.should == 412
      end

      it 'goes 412 when the etags do not match (JSON)' do

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          Rufus::Json.encode({}),
          {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_IF_MATCH' => '"foo"'
          }
        )

        last_response.status.should == 412
      end

      it 'does not go 412 when the etags match (HTML)' do

        rev = @exp.to_h['_rev']

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          { :fields => '{}' },
          { 'HTTP_IF_MATCH' => ('"%s"' % rev) }
        )

        last_response.status.should_not == 412
      end

      it 'does not go 412 when the etags match (JSON)' do

        rev = @exp.to_h['_rev']

        put(
          "/_ruote/expressions/#{@exp.fei.sid}",
          Rufus::Json.encode({}),
          {
            'CONTENT_TYPE' => 'application/json',
            'HTTP_IF_MATCH' => ('"%s"' % rev )
          }
        )

        last_response.status.should_not == 412
      end
    end
  end
end

