require File.dirname(__FILE__) + '/../spec_helper'

describe "GET /expressions" do
  it "should report a friendly message to the user (HTML)" do
    get "/expressions"

    last_response.should be_ok
  end

  it "should report a friendly message to the client (JSON)" do
    get "/expressions.json"

    last_response.should be_ok

    last_response.json_body['status'].should == 'ok'
  end
end

describe "GET /expressions/wfid" do
  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process
    end

    it "should render the expression tree (HTML)" do
      get "/expressions/#{@wfid}"

      last_response.should be_ok
    end

    it "should render the expression tree (JSON)" do
      get "/expressions/#{@wfid}.json"

      last_response.should be_ok
    end
  end

  describe "without running processes" do
    it "should 404 correctly (HTML)" do
      get "/expressions/foo"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it "should 404 correctly (JSON)" do
      get "/expressions/foo.json"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end

describe "GET /expressions/wfid/expid" do
  describe "with running processes" do
    before(:each) do
      @wfid = launch_test_process
      process = RuoteKit.engine.process( @wfid )
      @nada_exp_id = process.expressions.last.fei.expid
    end

    it "should render the expression details (HTML)" do
      get "/expressions/#{@wfid}/#{@nada_exp_id}"

      last_response.should be_ok
    end

    it "should render the expression details (JSON)" do
      get "/expressions/#{@wfid}/#{@nada_exp_id}.json"

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

describe "DELETE /expressions/wfid/expid" do
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

      wait_exp = RuoteKit.engine.process( @wfid ).expressions.last
      @expid = wait_exp.fei.expid
    end

    it "should cancel the expressions (HTML)" do
      delete "/expressions/#{@wfid}/#{@expid}"

      last_response.should be_redirect
      last_response['Location'].should == "/expressions/#{@wfid}"

      sleep 0.4

      @tracer.to_s.should == "bailed\ndone"
    end

    it "should cancel the expressions (JSON)" do
      delete "/expressions/#{@wfid}/#{@expid}.json"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      sleep 0.4

      @tracer.to_s.should == "bailed\ndone"
    end

    it "should kill the expression (HTML)" do
      delete "/expressions/#{@wfid}/#{@expid}?_kill=1"

      last_response.should be_redirect
      last_response['Location'].should == "/expressions/#{@wfid}"

      sleep 0.4

      @tracer.to_s.should == "done"
    end

    it "should kill the expression (JSON)" do
      delete "/expressions/#{@wfid}/#{@expid}.json?_kill=1"

      last_response.should be_ok
      last_response.json_body['status'].should == 'ok'

      sleep 0.4

      @tracer.to_s.should == "done"
    end
  end

  describe "without running processes" do
    it "should 404 correctly (HTML)" do
      delete "/expressions/foo/bar"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end

    it "should 404 correctly (JSON)" do
      delete "/expressions/foo/bar.json"

      last_response.should_not be_ok
      last_response.status.should be(404)
    end
  end
end
