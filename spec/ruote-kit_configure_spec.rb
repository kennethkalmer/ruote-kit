
require File.join(File.dirname(__FILE__), 'spec_helper.rb')

undef :context if defined?(context)

class MyCustomStorage
  attr_reader :opts
  def initialize (opts)
    @opts = opts
  end
end

class MyParticipant
end

describe RuoteKit do

  describe 'configure' do

    before(:each) do
      # nothing
    end

    it 'should default to :transient' do

      RuoteKit.configuration.mode.should == :transient
    end
  end

  describe 'configure with a custom storage' do

    before(:each) do

      RuoteKit.configure do |conf|
        #require 'path/to/my_custom_storage'
        conf.set_storage( MyCustomStorage, :a => 'A', :b => 'B' )
        conf.run_engine = false
      end
    end

    after(:each) do
      RuoteKit.reset_configuration!
    end

    it 'should advertise mode as :custom' do

      RuoteKit.configuration.mode.should == :custom
    end

    it 'should return an instance of the customer storage' do

      si = RuoteKit.configuration.storage_instance

      si.class.should == MyCustomStorage
      si.opts.should == { :a => 'A', :b => 'B' }
    end
  end

  describe 'register participants' do

    require 'ruote/participant'

    describe 'custom participant' do
      RuoteKit.configure do |conf|
        conf.register do
          participant 'al', MyParticipant
        end
      end

      RuoteKit.engine.context.plist.names.should == ['^al$']
    end

    describe 'catchall participant' do
      RuoteKit.configure do |conf|
        conf.register do
          catchall MyParticipant
        end
      end

      RuoteKit.engine.context.plist.names.should == [ '^.+$' ]
    end

    describe 'catchall participant without any options' do
      require 'ruote/part/storage_participant'

      RuoteKit.configure do |conf|
        conf.register do
          catchall
        end
      end

      RuoteKit.engine.context.plist.lookup('.+').instance_of?(Ruote::StorageParticipant).should == true
    end

    after do
      RuoteKit.reset_configuration!
    end
  end
end

