require File.dirname(__FILE__) + '/../spec_helper'

describe "process.html.haml" do
  before(:each) do
    @wfid = launch_test_process
    @process = RuoteKit.engine.process( @wfid )

    assigns[:process] = @process

    render 'process.html.haml'
  end

  it "should have the process name" do
    response.should include(@wfid)
  end
end
