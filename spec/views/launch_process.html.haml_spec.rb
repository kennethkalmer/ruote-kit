require File.dirname(__FILE__) + '/../spec_helper'

describe "launch_process.html.haml" do
  it "should have a process definition field" do
    render 'launch_process.html.haml'

    response.should have_selector('textarea', :name => 'process_definition')
  end

  it "should have a process URI field if remote processes are allowed" do
    render 'launch_process.html.haml'

    response.should have_selector('input', :name => 'process_uri')
  end

  it "should not have a process URI field if remote processes are disabled"

  it "should have a workitem fields field" do
    render 'launch_process.html.haml'

    response.should have_selector('textarea', :name => 'process_fields')
  end
end
