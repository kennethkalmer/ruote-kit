require File.dirname(__FILE__) + '/../spec_helper'

describe "processes.html.haml" do
  describe "without processes" do
    before(:each) do
      assigns[:processes] = []

      render( 'processes.html.haml' )
    end

    it "should give a nice notice" do
      response.should contain(/No processes are currently running/)
    end
  end
end
