
require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'processes.html.haml' do

  it_has_an_engine

  describe 'without processes' do

    before( :each ) do

      assigns[:processes] = []
      render 'processes.html.haml'
    end

    it 'should give a nice notice' do

      response.should contain( /No processes are currently running/ )
    end
  end

  describe 'with processes' do

    before( :each ) do

      @wfid = launch_test_process
      @process = engine.process( @wfid )

      assigns[:processes] = [ @process ]

      render 'processes.html.haml'
    end

    it 'should count the processes' do

      response.should contain( /Currently running 1 processes/ )
    end
  end
end

