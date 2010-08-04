
require File.join(File.dirname(__FILE__), '/../spec_helper')

undef :context if defined?(context)


describe 'GET /_ruote/schedules' do

  it_has_an_engine

  before(:each) do

    @wfid = RuoteKit.engine.launch(Ruote.define do
      sequence do
        alpha :timeout => '2d'
      end
    end)

    RuoteKit.engine.wait_for(:alpha)
  end

  it 'should list schedules (HTML)' do

    get '/_ruote/schedules'

    last_response.status.should be(200)
  end

  it 'should list schedules (JSON)' do

    get '/_ruote/schedules.json'

    last_response.status.should be(200)

    #puts Rufus::Json.pretty_encode(last_response.json_body)

    last_response.json_body['schedules'].first.keys.sort.should == %w[
      _id action at flavour links original owner put_at target type
    ]
  end
end

