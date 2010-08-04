
require File.join(File.dirname(__FILE__), '/../spec_helper')

undef :context if defined?(context)


describe 'GET /_ruote/schedules' do

  it_has_an_engine

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
  end

  it 'should list schedules (HTML)' do

    get '/_ruote/schedules'

    last_response.status.should be(200)

    last_response.should have_selector(
      'a[rel="http://ruote.rubyforge.org/rels.html#process_schedules"]')
  end

  it 'should list schedules (JSON)' do

    get '/_ruote/schedules.json'

    last_response.status.should be(200)

    #puts Rufus::Json.pretty_encode(last_response.json_body)

    last_response.json_body['schedules'].size.should == 2

    last_response.json_body['schedules'].first.keys.sort.should == %w[
      _id action at flavour links original owner put_at target type wfid
    ]
  end
end

describe 'GET /_ruote/schedules/wfid' do

  it_has_an_engine

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
  end

  it 'should list schedules (HTML)' do

    get "/_ruote/schedules/#{@wfid1}"

    last_response.status.should be(200)
  end

  it 'should list schedules (JSON)' do

    get "/_ruote/schedules/#{@wfid0}.json"

    last_response.status.should be(200)

    #puts Rufus::Json.pretty_encode(last_response.json_body)

    last_response.json_body['schedules'].size.should == 1
  end
end

