
require 'spec_helper'


describe RuoteKit do

  context 'with an orphan workitem' do

    before(:all) do

      prepare_engine_with_participants

      pdef = Ruote.process_definition :name => 'test' do
        toto
      end

      #RuoteKit.engine.noisy = true

      @wfid = RuoteKit.engine.launch(pdef)
      RuoteKit.engine.wait_for(:toto)
      RuoteKit.engine.wait_for(1)

      @wi = RuoteKit.engine.storage_participant.first

      RuoteKit.engine.cancel(@wfid)
      RuoteKit.engine.wait_for('terminated')

      @wi.h.delete('_rev')
      RuoteKit.engine.storage.put(@wi.h)
    end

    after(:all) do

      shutdown_and_purge_engine
    end

    describe 'GET /_ruote/processes' do

      it 'does not list the process' do

        get '/_ruote/processes.json'

        last_response.status.should == 200

        last_response.json_body['processes'].should == []
      end
    end

    describe 'GET /_ruote/workitems' do

      it 'lists the orphan workitem' do

        get '/_ruote/workitems.json'

        last_response.status.should == 200

        last_response.json_body['workitems'].size.should == 1
        last_response.json_body['workitems'][0]['id'].should == @wi.sid

        links = last_response.json_body['workitems'][0]['links']

        link_for(links, 'self').should ==
          "/_ruote/workitems/#{@wi.sid}"
        link_for(links, '#expression').should ==
          "/_ruote/expressions/#{@wi.sid}"
      end
    end

    describe 'GET /_ruote/workitems/:wfid' do

      it 'lists the orphan workitems' do

        get "/_ruote/workitems/#{@wi.wfid}.json"

        last_response.status.should == 200

        last_response.json_body['workitems'].size.should == 1
        last_response.json_body['workitems'][0]['id'].should == @wi.sid
      end
    end

    describe 'GET /_ruote/workitems/:fei' do

      it 'renders the workitem' do

        get "/_ruote/workitems/#{@wi.sid}.json"

        last_response.status.should == 200

        links = last_response.json_body['links']

        link_for(links, 'self').should == "/_ruote/workitems/#{@wi.sid}"
      end
    end

    describe 'GET /_ruote/processes/:wfid' do

      it 'goes 404 (HTML)' do

        get "/_ruote/processes/#{@wi.wfid}"

        last_response.status.should == 404
      end

      it 'goes 404 (JSON)' do

        get "/_ruote/processes/#{@wi.wfid}.json"

        last_response.status.should == 404
      end
    end

    describe 'GET /_ruote/expressions/:fei' do

      it 'goes 404' do

        get "/_ruote/expressions/#{@wi.sid}.json"

        last_response.status.should == 404
      end
    end

    describe 'GET /_ruote/expressions/:wfid' do

      it 'goes 404 (HTML)' do

        get "/_ruote/expressions/#{@wi.wfid}"

        last_response.status.should == 404
      end

      it 'goes 404 (JSON)' do

        get "/_ruote/expressions/#{@wi.wfid}.json"

        last_response.status.should == 404
      end
    end
  end
end

