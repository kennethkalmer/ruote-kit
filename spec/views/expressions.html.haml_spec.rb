require File.dirname(__FILE__) + '/../spec_helper'


undef :context if defined?(context)


describe "expressions.html.haml", :type => :with_engine do

  describe "without expressions" do
    it "should be helpful" do
      render "expressions.html.haml"

      response.should match(/Expressions are atomic pieces of process instances/)
    end
  end

  describe "with expressions" do
    before(:each) do
      @wfid = launch_test_process
      @process = engine.process( @wfid )

      assigns[:process] = @process

      render 'expressions.html.haml'
    end

    it "should have the process id" do
      response.should include(@wfid)
    end
  end
end
