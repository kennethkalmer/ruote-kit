require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /_ruote/expressions", :type => :with_engine do

  it "should report a friendly message to the user (HTML)" do
    get "/_ruote/expressions"

    last_response.should be_ok
  end

  it "should report a friendly message to the client (JSON)" do
    get "/_ruote/expressions.json"

    last_response.should be_ok

    last_response.json_body['status'].should == 'ok'
  end
end

describe "GET /_ruote/expressions/wfid", :type => :with_engine do

  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process
    end

    it "should render the expression tree (HTML)" do
      get "/_ruote/expressions/#{@wfid}"

      last_response.should be_ok
    end

    it "should render the expression tree (JSON)" do
      get "/_ruote/expressions/#{@wfid}.json"

      last_response.should be_ok
    end
  end

  describe "without running processes" do
    it "should 404 correctly (HTML)" do
      get "/_ruote/expressions/foo"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it "should 404 correctly (JSON)" do
      get "/_ruote/expressions/foo.json"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe "GET /_ruote/expressions/wfid/expid", :type => :with_engine do

  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process
      process = engine.process( @wfid )
      @nada_exp_id = process.expressions.last.fei.expid
    end

    it "should render the expression details (HTML)" do
      get "/_ruote/expressions/#{@wfid}/#{@nada_exp_id}"

      last_response.should be_ok
    end

    it "should render the expression details (JSON)" do
      get "/_ruote/expressions/#{@wfid}/#{@nada_exp_id}.json"

      last_response.should be_ok
    end
  end

  describe "without running processes" do
    it "should 404 correctly (HTML)" do
      get "/workitems/foo/bar"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it "should 404 correctly (JSON)" do
      get "/workitems/foo/bar.json"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe "DELETE /_ruote/expressions/wfid/expid", :type => :with_engine do

  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process do
        Ruote.process_definition :name => 'delete' do
          sequence do
            wait '1d', :on_cancel => 'bail_out'
            echo 'done'
          end

          define 'bail_out' do
            sequence do
              echo 'bailed'
            end
          end
        end
      end

      wait_exp = engine.process( @wfid ).expressions.last
      @expid = "0_1_0" #wait_exp.fei.expid
    end

    it "should cancel the expressions (HTML)" do
      delete "/_ruote/expressions/#{@wfid}/#{@expid}"

      last_response.should be_redirect
      last_response['Location'].should == "/_ruote/expressions/#{@wfid}"

      #sleep 0.4
      wait_for( @wfid )

      @tracer.to_s.should == "bailed\ndone"
    end

    it "should cancel the expressions (JSON)" do
      delete "/_ruote/expressions/#{@wfid}/#{@expid}.json"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      #sleep 0.4
      wait_for( @wfid )

      @tracer.to_s.should == "bailed\ndone"
    end

    it "should kill the expression (HTML)" do
      delete "/_ruote/expressions/#{@wfid}/#{@expid}?_kill=1"

      last_response.should be_redirect
      last_response['Location'].should == "/_ruote/expressions/#{@wfid}"

      #sleep 0.4
      wait_for( @wfid )

      @tracer.to_s.should == "done"
    end

    it "should kill the expression (JSON)" do
      delete "/_ruote/expressions/#{@wfid}/#{@expid}.json?_kill=1"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      #sleep 0.4
      wait_for( @wfid )

      @tracer.to_s.should == "done"
    end
  end

  describe "without running processes" do
    it "should 404 correctly (HTML)" do
      delete "/_ruote/expressions/foo/bar"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it "should 404 correctly (JSON)" do
      delete "/_ruote/expressions/foo/bar.json"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end
