
require File.join(File.dirname(__FILE__), '/../spec_helper')

undef :context if defined?(context)


describe 'without any running processes' do

  it_has_an_engine_with_no_participants

  describe 'GET /_ruote/errors' do

    it 'should give no processes back (HTML)' do

      get '/_ruote/errors'

      last_response.status.should be(200)
    end

    it 'should give an empty array (JSON)' do

      get '/_ruote/errors.json'

      last_response.status.should be(200)

      body = last_response.json_body
      body.should have_key('errors')

      body['errors'].should be_empty
    end
  end
end

describe 'with a running process that has an error' do

  it_has_an_engine_with_no_participants

  before(:each) do

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
  end

  describe 'GET /_ruote/errors' do

    it 'should list errors (HTML)' do

      get '/_ruote/errors'

      last_response.status.should be(200)
      last_response.should match(/nemo/)
    end

    it 'should list errors (JSON)' do

      get '/_ruote/errors.json'

      last_response.status.should be(200)

      json = last_response.json_body

      # global links

      json['links'].should == root_links('/_ruote/errors')

      # the error itself

      json['errors'].size.should == 1
      json['errors'].first['message'].should == "#<RuntimeError: unknown participant or subprocess 'nemo'>"

      # the links for the error itself

      json['errors'].first['links'].should == [
        { 'href' => "/_ruote/errors/0_0_0!!#{@wfid}",
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

    it 'should list process errors (HTML)' do

      get "/_ruote/errors/#{@wfid}"

      last_response.status.should be(200)
      last_response.should match(/nemo/)
    end

    it 'should list process errors (JSON)' do

      get "/_ruote/errors/#{@wfid}.json"

      last_response.status.should be(200)

      json = last_response.json_body

      json['links'].should == root_links("/_ruote/errors/#{@wfid}")
      json['errors'].size.should == 1
      json['errors'].first['message'].should == "#<RuntimeError: unknown participant or subprocess 'nemo'>"
    end
  end

  describe 'GET /_ruote/errors/:fei' do

    it 'should show the error (HTML)' do

      get "/_ruote/errors/0_0_0!!#{@wfid}"

      last_response.status.should be(200)
      last_response.should match(/nemo/)
    end

    it 'should show the error (JSON)' do

      get "/_ruote/errors/0_0_0!!#{@wfid}.json"

      last_response.status.should be(200)

      json = last_response.json_body

      #puts Rufus::Json.pretty_encode(json)
    end
  end

  describe 'DELETE /_ruote/errors/:fei' do

    it 'should replay errors (HTML)' do

      RuoteKit.engine.register_participant :nemo, Ruote::StorageParticipant

      delete "/_ruote/errors/#{@error.fei.sid}"

      last_response.status.should be(302)
      last_response['Location'].should == '/_ruote/errors'

      RuoteKit.engine.wait_for(:nemo)

      RuoteKit.engine.storage_participant.size.should == 1

      wi = RuoteKit.engine.storage_participant.first
      wi.participant_name.should == 'nemo'

      RuoteKit.engine.process(@wfid).errors.size.should == 0
    end

    it 'should replay errors (JSON)' do

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

