
require File.dirname(__FILE__) + '/../spec_helper'

class BrokenParticipant
  include Ruote::LocalParticipant
  def initialize(opts)
  end
  def consume (workitem)
    raise 'broken'
  end
end


describe 'GET /_ruote/errors' do

  it_has_an_engine_with_no_participants

  describe 'without any running processes' do

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

  describe 'with a running process that has an error' do

    before(:each) do

      RuoteKit.engine.register_participant :broken, BrokenParticipant
      RuoteKit.engine.register_participant :alice, Ruote::StorageParticipant

      @wfid = launch_test_process do
        Ruote.process_definition :name => 'test' do
          sequence do
            broken
            alice
          end
        end
      end
    end

    it 'should list errors (HTML)' do

      get '/_ruote/errors'

      last_response.status.should be(200)
      last_response.should match(/broken/)
    end

    it 'should list errors (JSON)' do

      get '/_ruote/errors.json'

      last_response.status.should be(200)

      json = last_response.json_body

      # global links

      json['links'].should == root_links('/_ruote/errors')

      # the error itself

      json['errors'].size.should == 1
      json['errors'].first['message'].should == '#<RuntimeError: broken>'

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

    it 'should list process errors (HTML)' do

      get "/_ruote/errors/#{@wfid}"

      last_response.status.should be(200)
      last_response.should match(/broken/)
    end

    it 'should list process errors (JSON)' do

      get "/_ruote/errors/#{@wfid}.json"

      last_response.status.should be(200)

      json = last_response.json_body

      json['links'].should == root_links("/_ruote/errors/#{@wfid}")
      json['errors'].size.should == 1
      json['errors'].first['message'].should == '#<RuntimeError: broken>'
    end

    it 'should show the error (HTML)' do

      get "/_ruote/errors/0_0_0!!#{@wfid}"

      last_response.status.should be(200)
      last_response.should match(/broken/)
    end

    it 'should show the error (JSON)' do

      get "/_ruote/errors/0_0_0!!#{@wfid}.json"

      last_response.status.should be(200)

      json = last_response.json_body

      #puts Rufus::Json.pretty_encode(json)
    end

    it 'should replay errors (HTML)' do

      pending 'wip'
    end

    it 'should replay errors (JSON)' do

      pending 'wip'
    end
  end
end

