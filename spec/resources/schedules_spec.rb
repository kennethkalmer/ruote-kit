
require 'spec_helper'


describe '/_ruote/schedules' do

  before(:each) do
    prepare_engine_with_participants
  end
  after(:each) do
    shutdown_and_purge_engine
  end

  describe 'GET /_ruote/schedules' do

    before(:each) do

      @wfid0 = RuoteKit.engine.launch(Ruote.define do
        wait :for => '3d'
      end)
      @wfid1 = RuoteKit.engine.launch(Ruote.define do
        sequence do
          alpha :timeout => '2d'
        end
      end)
      @wfid2 = RuoteKit.engine.launch(Ruote.define do
         nada
      end)

      RuoteKit.engine.wait_for(:alpha)
    end

    it 'lists schedules (HTML)' do

      get '/_ruote/schedules'

      last_response.status.should be(200)

      last_response.should have_selector(
        'a[rel="http://ruote.rubyforge.org/rels.html#process_schedules"]')

      last_response.should contain('1 to 2 of 2 schedules')
    end

    it 'lists schedules (JSON)' do

      get '/_ruote/schedules.json'

      last_response.status.should be(200)

      json = last_response.json_body
      #puts Rufus::Json.pretty_encode(json)

      schedules = json['schedules']

      schedules.size.should == 2

      schedules.first.keys.sort.should == %w[
        _id action at flavour links original owner put_at target type wfid
      ]

      schedules.first['target'].should be_kind_of(Hash)
      schedules.first['owner'].should be_kind_of(Hash)

      hrefs = schedules.collect { |s| s['links'].first['href'] }
      prefixes = hrefs.collect { |h| h.split('!').first }.sort
      suffixes = hrefs.collect { |h| h.split('!').last }.sort

      hrefs = schedules.collect { |s|
        s['links'].first['href']
      }.collect { |h|
        pieces = h.split('!')
        pieces.first + '/' + pieces.last
      }.sort

      hrefs.should ==
        [ "/_ruote/expressions/0_0/#{@wfid0}",
          "/_ruote/expressions/0_0_0/#{@wfid1}" ]
    end
  end

  describe 'GET /_ruote/schedules/:wfid' do

    before(:each) do

      @wfid0 = RuoteKit.engine.launch(Ruote.define do
        wait :for => '3d'
      end)
      @wfid1 = RuoteKit.engine.launch(Ruote.define do
        sequence do
          alpha :timeout => '2d'
        end
      end)

      RuoteKit.engine.wait_for(:alpha)

      @wfid2 = RuoteKit.engine.launch(Ruote.define do
        bravo :timers => '1d: x, 2d: timeout'
      end)

      RuoteKit.engine.wait_for(:bravo)
    end

    it 'lists schedules (HTML)' do

      get "/_ruote/schedules/#{@wfid1}"

      last_response.status.should be(200)
    end

    it 'lists schedules (JSON)' do

      get "/_ruote/schedules/#{@wfid0}.json"

      last_response.status.should be(200)

      #puts Rufus::Json.pretty_encode(last_response.json_body)

      last_response.json_body['schedules'].size.should == 1
    end

    it 'list schedules with timers (nil target) (HTML)' do

      get "/_ruote/schedules/#{@wfid2}"

      last_response.status.should be(200)
    end

    it 'list schedules with timers (nil target) (JSON)' do

      get "/_ruote/schedules/#{@wfid2}.json"

      last_response.status.should be(200)
    end
  end
end

