
require File.dirname( __FILE__ ) + '/../spec_helper'

class BrokenParticipant
  include Ruote::LocalParticipant
  def initialize( opts )
  end
  def consume ( workitem )
    raise 'broken'
  end
end


describe 'GET /_ruote/errors' do

  it_has_an_engine

  describe 'without any running processes' do

    it 'should give no processes back (HTML)' do

      get '/_ruote/errors'

      last_response.status.should be( 200 )
    end

    it 'should give an empty array (JSON)' do

      get '/_ruote/errors.json'

      last_response.status.should be( 200 )

      body = last_response.json_body
      body.should have_key( 'errors' )

      body['errors'].should be_empty
    end
  end

  describe 'with a running process that has an error' do

    before( :each ) do

      RuoteKit.engine.register_participant :broken, BrokenParticipant

      @wfid = launch_test_process do
        Ruote.process_definition :name => 'test' do
          broken
        end
      end
    end

#    it 'should list errors (HTML)' do
#
#      get '/_ruote/errors'
#
#      last_response.status.should be( 200 )
#      last_response.should match( /broken/ )
#
#      #p last_response.body
#
#      # TODO : continue me
#    end

    it 'should list errors (JSON)' do

      get '/_ruote/errors.json'

      last_response.status.should be( 200 )

      # TODO : continue me
    end
  end
end

