require 'spec_helper'

undef :context if defined?(context)


describe RuoteKit do

#  describe 'run_worker' do
#
#    before(:each) do
#      RuoteKit.run_worker(Ruote::HashStorage.new)
#    end
#
#    it 'should instantiate an engine' do
#      RuoteKit.engine.should_not == nil
#    end
#
#    it 'should instantiate an engine with a worker' do
#      RuoteKit.engine.worker.should_not == nil
#    end
#
#    it 'should instantiate an engine bound to a storage' do
#      RuoteKit.engine.storage.class.should == Ruote::HashStorage
#    end
#  end

  describe 'bind_engine' do

    before(:each) do
      RuoteKit.bind_engine(Ruote::HashStorage.new)
    end

    it 'should instantiate an engine' do
      RuoteKit.engine.should_not == nil
    end

    it 'should instantiate an engine without a worker' do
      RuoteKit.engine.worker.should == nil
    end

    it 'should instantiate an engine bound to a storage' do
      RuoteKit.engine.storage.class.should == Ruote::HashStorage
    end
  end

  describe 'direct engine setting' do

    # stupid illustrative spec

    it 'should comply' do
      RuoteKit.engine = Ruote::Engine.new(Ruote::HashStorage.new)
      RuoteKit.engine.should_not == nil
    end
  end
end

