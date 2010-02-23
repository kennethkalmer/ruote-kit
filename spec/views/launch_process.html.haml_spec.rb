require File.dirname(__FILE__) + '/../spec_helper'

describe "launch_process.html.haml", :type => :with_engine do

  it "should have a process definition field" do
    render 'launch_process.html.haml'

    response.should have_selector('textarea', :name => 'process_definition')
  end

  it "should have a workitem fields field" do
    render 'launch_process.html.haml'

    response.should have_selector('textarea', :name => 'process_fields')
  end

  it "should have a workitem variables field" do
    render 'launch_process.html.haml'

    response.should have_selector('textarea', :name => 'process_variables')
  end
end
