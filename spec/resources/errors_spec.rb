
require 'spec_helper'


describe '/_ruote/errors' do

  context 'without any running processes' do

    before(:each) do
      prepare_engine
    end
    after(:each) do
      shutdown_and_purge_engine
    end

    describe 'GET /_ruote/errors' do

      it 'gives no processes back (HTML)' do

        get '/_ruote/errors'

        last_response.status.should be(200)
      end

      it 'gives an empty array (JSON)' do

        get '/_ruote/errors.json'

        last_response.status.should be(200)

        body = last_response.json_body
        body.should have_key('errors')

        body['errors'].should be_empty
      end
    end
  end

  context 'with a running process that has no errors' do

    before(:each) do

      prepare_engine

      @wfid = RuoteKit.engine.launch(
        Ruote.define do
          stall # sit there and do nothing
        end
      )

      RuoteKit.engine.wait_for(2)
    end

    describe 'GET /_ruote/errors/:wfid' do

      it 'returns an empty list' do

        get "/_ruote/errors/#{@wfid}"

        last_response.status.should == 200
      end
    end
  end

  context 'with a running process that has an error' do

    before(:each) do

      prepare_engine

      RuoteKit.engine.register_participant :alice, Ruote::StorageParticipant

      @wfid = RuoteKit.engine.launch(
        Ruote.process_definition(:name => 'test') do
          sequence do
            nemo
            alice
          end
        end
      )

      RuoteKit.engine.wait_for(@wfid)

      @error = RuoteKit.engine.process(@wfid).errors.first
      @fei = @error.fei
    end

    describe 'GET /_ruote/errors' do

      it 'lists errors (HTML)' do

        get '/_ruote/errors'

        last_response.status.should be(200)
        last_response.should match(/nemo/)
      end

      it 'lists errors (JSON)' do

        get '/_ruote/errors.json'

        last_response.status.should be(200)

        json = last_response.json_body

        # global links

        json['links'].should == [
          { 'href' => '/_ruote',
            'rel' => 'http://ruote.rubyforge.org/rels.html#root'  },
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
          { 'href' => '/_ruote/errors',
            'rel' => 'self' },
          { 'href' => '/_ruote/errors',
            'rel' => 'all' },
          { 'href' => '/_ruote/errors?limit=100&skip=0',
            'rel' => 'first' },
          { 'href' => '/_ruote/errors?limit=100&skip=0',
            'rel' => 'last' },
          { 'href' => '/_ruote/errors?limit=100&skip=0',
            'rel' => 'previous' },
          { 'href' => '/_ruote/errors?limit=100&skip=0',
            'rel' => 'next' } ]

        # the error itself

        json['errors'].size.should == 1
        json['errors'].first['message'].should == "#<RuntimeError: unknown participant or subprocess 'nemo'>"

        # the links for the error itself

        json['errors'].first['links'].should == [
          { 'href' => "/_ruote/errors/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
            'rel' => 'self' },
          { 'href' => "/_ruote/errors/#{@wfid}",
            'rel' => 'http://ruote.rubyforge.org/rels.html#process_errors' },
          { 'href' => "/_ruote/processes/#{@wfid}",
            'rel' => 'http://ruote.rubyforge.org/rels.html#process' }
        ]

        #puts Rufus::Json.pretty_encode(json)
      end
    end

    describe 'GET /_ruote/errors/:wfid' do

      it 'lists process errors (HTML)' do

        get "/_ruote/errors/#{@wfid}"

        last_response.status.should be(200)
        last_response.should match(/nemo/)
      end

      it 'lists process errors (JSON)' do

        get "/_ruote/errors/#{@wfid}.json"

        last_response.status.should be(200)

        json = last_response.json_body

        json['errors'].size.should == 1
        json['errors'].first['message'].should == "#<RuntimeError: unknown participant or subprocess 'nemo'>"

        json['errors'].first['links'].should == [
          { 'href' => "/_ruote/errors/#{@fei.expid}!#{@fei.subid}!#{@wfid}",
            'rel' => 'self' },
          { 'href' => "/_ruote/errors/#{@wfid}",
            'rel' => 'http://ruote.rubyforge.org/rels.html#process_errors' },
          { 'href' => "/_ruote/processes/#{@wfid}",
            'rel' => 'http://ruote.rubyforge.org/rels.html#process' } ]
      end
    end

    describe 'GET /_ruote/errors/:fei' do

      it 'shows the error (HTML)' do

        get "/_ruote/errors/#{@error.fei.sid}"

        last_response.status.should be(200)
        last_response.should match(/nemo/)
        last_response.should match(/details/)
      end

      it 'shows the error (JSON)' do

        get "/_ruote/errors/#{@error.fei.sid}.json"

        last_response.status.should be(200)

        json = last_response.json_body

        #pp json

        json.should have_key('error')
        json['error'].should have_key('at')
        json['error'].should have_key('details')
      end
    end

    describe 'DELETE /_ruote/errors/:fei' do

      it 'replays errors (HTML)' do

        RuoteKit.engine.register_participant :nemo, Ruote::StorageParticipant

        delete "/_ruote/errors/#{@error.fei.sid}"

        last_response.status.should be(302)
        last_response['Location'].should == 'http://example.org/_ruote/errors'

        RuoteKit.engine.wait_for(:nemo)

        RuoteKit.engine.storage_participant.size.should == 1

        wi = RuoteKit.engine.storage_participant.first
        wi.participant_name.should == 'nemo'

        RuoteKit.engine.process(@wfid).errors.size.should == 0
      end

      it 'replays errors (JSON)' do

        #RuoteKit.engine.noisy = true

        RuoteKit.engine.register_participant :nemo, Ruote::StorageParticipant

        delete "/_ruote/errors/#{@error.fei.sid}.json"

        last_response.status.should be(200)
        last_response.json_body['status'].should == 'ok'

        RuoteKit.engine.wait_for(:nemo)

        RuoteKit.engine.storage_participant.size.should == 1

        wi = RuoteKit.engine.storage_participant.first
        wi.participant_name.should == 'nemo'

        RuoteKit.engine.process(@wfid).errors.size.should == 0
      end
    end
  end
end

