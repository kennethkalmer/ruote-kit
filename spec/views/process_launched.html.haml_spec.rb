require File.dirname(__FILE__) + '/../spec_helper'

describe "process_launched.html.haml" do

  it_should_behave_like 'an engine powered spec'

  before(:each) do
    @wfid = launch_test_process

    assigns[:wfid] = @wfid

    render 'process_launched.html.haml'
  end

  it "should have the process id" do
    response.should include(@wfid)
  end
end
