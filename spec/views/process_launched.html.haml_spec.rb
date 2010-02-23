require File.dirname(__FILE__) + '/../spec_helper'

describe "process_launched.html.haml", :type => :with_engine do

  before(:each) do
    @wfid = launch_test_process

    assigns[:wfid] = @wfid

    render 'process_launched.html.haml'
  end

  it "should have the process id" do
    response.should include(@wfid)
  end
end
