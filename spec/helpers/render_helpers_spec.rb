require File.dirname(__FILE__) + '/../spec_helper'

describe "json helper" do
  describe "rendering defaults" do
    before(:each) do
      stub_chain( :request, :fullpath ).and_return('/')

      @hash = Ruote::Json.decode( json( :status, :ok ) )
    end

    it "should have the key & value" do
      @hash.should have_key('status')
      @hash['status'].should == 'ok'
    end

    it "should have a collection of links" do
      @hash.should have_key('links')
      @hash['links'].should_not be_empty
    end

    it "should link to 'self'" do
      @hash['links'].detect { |l| l['rel'] == 'self' && l['href'] == '/' }.should_not be_nil
    end

    it "should link to the root" do
      @hash['links'].detect { |l| l['rel'] =~ /#root$/ && l['href'] == '/' }.should_not be_nil
    end

    it "should link to the processes" do
      @hash['links'].detect { |l| l['rel'] =~ /#processes$/ && l['href'] == '/processes' }.should_not be_nil
    end

    it "should not link to the expressions by default" do
      @hash['links'].detect { |l| l['rel'] =~ /#expressions$/ && l['href'] == '/expressions' }.should be_nil
    end

    it "should link to the workitems" do
      @hash['links'].detect { |l| l['rel'] =~ /#workitems$/ && l['href'] == '/workitems' }.should_not be_nil
    end
  end

  describe "rendering processes" do
    before(:each) do
      stub_chain( :request, :fullpath ).and_return('/processes')

      @wfid = launch_test_process
      process = RuoteKit.engine.process( @wfid )

      @hash = Ruote::Json.decode( json( :processes, [process] ) )
    end

    it "should have a collection of processes" do
      @hash.should have_key('processes')
      @hash['processes'].should_not be_empty
    end

    describe "in detail, and" do
      before(:each) do
        @process = @hash['processes'].first

        @process.should have_key('links')
      end

      it "should link to the process details" do

        @process['links'].detect { |l| l['rel'] =~ /#process/ && l['href'] == "/processes/#{@wfid}" }.should_not be_nil
      end

      it "should link to the process expressions" do

        @process['links'].detect { |l| l['rel'] =~ /#expressions/ && l['href'] == "/expressions/#{@wfid}" }.should_not be_nil
      end

      it "should link to the process workitems" do

        @process['links'].detect { |l| l['rel'] =~ /#workitems/ && l['href'] == "/workitems/#{@wfid}" }.should_not be_nil
      end
    end

  end
end
