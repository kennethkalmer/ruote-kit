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
      process = engine.process( @wfid )

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

  describe "rendering a single process" do
    before(:each) do
      @wfid = launch_test_process

      stub_chain( :request, :fullpath ).and_return("/processes/#{@wfid}")

      process = engine.process( @wfid )

      @hash = Ruote::Json.decode( json( :process, process ) )
    end

    it "should have the process details" do
      @hash.should have_key('process')
    end

    it "should link to the process details" do

      @hash['process']['links'].detect { |l| l['rel'] =~ /#process/ && l['href'] == "/processes/#{@wfid}" }.should_not be_nil
    end

    it "should link to the process expressions" do

      @hash['process']['links'].detect { |l| l['rel'] =~ /#expressions/ && l['href'] == "/expressions/#{@wfid}" }.should_not be_nil
    end

    it "should link to the process workitems" do

      @hash['process']['links'].detect { |l| l['rel'] =~ /#workitems/ && l['href'] == "/workitems/#{@wfid}" }.should_not be_nil
    end
  end

  describe "render a single expression" do
    before(:each) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          sequence do
            nada :activity => 'work your magic'
          end
        end
      end

      @expid = '0_0_0'

      stub_chain( :request, :fullpath ).and_return("/expressions/#{@wfid}/#{@expid}")

      process = engine.process( @wfid )
      expression = process.expressions.detect { |exp| exp.fei.expid == @expid }

      @hash = Ruote::Json.decode( json( :expression, expression ) )
    end

    it "should contain the expression" do
      @hash.should have_key('expression')
    end

    it "should link to the process" do
      @hash['expression']['links'].detect { |l| l['rel'] =~ /#process/ && l['href'] == "/processes/#{@wfid}" }.should_not be_nil
    end

    it "should link to the parent expression" do
      @hash['expression']['links'].detect { |l| l['rel'] == 'parent' && l['href'] == "/expressions/#{@wfid}/0_0" }.should_not be_nil
    end
  end

  describe "render an expression tree" do
    before(:each) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          sequence do
            nada :activity => 'work your magic'
          end
        end
      end

      stub_chain( :request, :fullpath ).and_return("/expressions/#{@wfid}")

      process = engine.process( @wfid )

      @hash = Ruote::Json.decode( json( :expressions, process.expressions ) )
    end

    it "should have the list of expressions" do
      @hash.should have_key('expressions')
    end
  end

  describe "rendering a workitem" do
    before(:each) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          sequence do
            nada :activity => 'work your magic'
          end
        end
      end

      stub_chain( :request, :fullpath ).and_return("/workitems/#{@wfid}/0_0_0")

      workitem = find_workitem( @wfid, '0_0_0' )

      @hash = Ruote::Json.decode( json( :workitem, workitem ) )
    end

    it "should have the workitem" do
      @hash.should have_key('workitem')
    end

  end

  describe "rendering workitems" do
    before(:each) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'foo' do
          sequence do
            nada :activity => 'work your magic'
          end
        end
      end

      stub_chain( :request, :fullpath ).and_return("/workitems")

      @hash = Ruote::Json.decode( json( :workitems, store_participant.all ) )
    end

    it "should have the workitems" do
      @hash.should have_key('workitems')
    end

  end
end
