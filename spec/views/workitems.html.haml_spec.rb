require File.dirname(__FILE__) + '/../spec_helper'

describe "workitems.html.haml", :type => :with_engine do

  describe "rendering no workitems" do
    before(:each) do
      assigns[:workitems] = []

      render 'workitems.html.haml'
    end

    it "should note so" do
      response.should have_selector('div.warn p', :content => "No workitems are currently available")
    end
  end

  describe "rendering all workitems" do
    before(:each) do
      @wfid1 = launch_test_process
      @wfid2 = launch_test_process

      assigns[:workitems] = storage_participant.all

      render 'workitems.html.haml'
    end

    it "should have a notice" do
      response.should have_selector('div.notice p', :content => "2 workitems available")
    end

    it "should show the processes" do
      response.should include(@wfid1)
      response.should include(@wfid2)
    end
  end

  describe "rendering process workitems" do
    before(:each) do
      @wfid = launch_test_process

      assigns[:wfid] = @wfid
      assigns[:workitems] = find_workitems( @wfid )

      render "workitems.html.haml"
    end

    it "should have a notice" do
      response.should have_selector('div.notice p', :content => "1 workitem available for #{@wfid}")
    end

    it "should show the process" do
      response.should include(@wfid)
    end
  end

  describe "rendering filtered workitems" do
    before(:each) do
      assigns[:workitems] = []
    end

    it "should show the participants used" do
      assigns[:participants] = ['jack']

      render 'workitems.html.haml'

      response.should have_selector('div.notice p', :content => "Filtered for participant(s): jack")
    end
  end
end
