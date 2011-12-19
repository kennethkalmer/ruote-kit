
require 'spec_helper'

undef :context if defined?(context)


describe RuoteKit do

#  describe 'run_worker' do
#
#    before(:each) do
#      RuoteKit.run_worker(Ruote::HashStorage.new)
#    end
#
#    it 'instantiates an engine' do
#      RuoteKit.engine.should_not == nil
#    end
#
#    it 'instantiates an engine with a worker' do
#      RuoteKit.engine.worker.should_not == nil
#    end
#
#    it 'instantiates an engine bound to a storage' do
#      RuoteKit.engine.storage.class.should == Ruote::HashStorage
#    end
#  end

  describe 'direct engine setting' do

    # stupid illustrative spec

    it 'complies' do
      RuoteKit.engine = Ruote::Engine.new(Ruote::HashStorage.new)
      RuoteKit.engine.should_not == nil
    end
  end

  describe '.bind_engine' do

    before(:each) do
      RuoteKit.bind_engine(Ruote::HashStorage.new)
    end

    it 'instantiates an engine' do
      RuoteKit.engine.should_not == nil
    end

    it 'instantiates an engine without a worker' do
      RuoteKit.engine.worker.should == nil
    end

    it 'instantiates an engine bound to a storage' do
      RuoteKit.engine.storage.class.should == Ruote::HashStorage
    end
  end

  describe '.engine' do

    it 'returns the Dashboard' do
      RuoteKit.engine.class.should == Ruote::Dashboard
    end
  end

  describe '.dashboard' do

    it 'returns the Dashboard' do
      RuoteKit.dashboard.class.should == Ruote::Dashboard
    end
  end

  describe '.storage_participant' do

    it 'returns the StorageParticipant' do
      RuoteKit.storage_participant.class.should == Ruote::StorageParticipant
    end
  end

  describe '.worklist' do

    it 'returns the StorageParticipant' do
      RuoteKit.worklist.class.should == Ruote::StorageParticipant
    end
  end
end

