
module RuoteKit

  # RuoteKit configuration handling
  class Configuration

    class ParticipantRegistrationProxy

      def self.participant( *args, &block )
        RuoteKit.engine.register_participant( *args, &block )
      end

      def self.catchall( *args, &block )
        if( args.empty? and not block_given? )
          require 'ruote/part/storage_participant'
          participant( '.+', Ruote::StorageParticipant )
        else
          participant( '.+', *args, &block )
        end
      end

      # looks at the given dir for .rb files
      def self.from_dir( dir )
        RuoteKit.engine.register_from_dir( dir )
      end
    end

    # Working directory for the engine (if using file system persistence)
    attr_accessor :work_directory

    # Whether to run a single worker or not (defaults to false)
    attr_accessor :run_worker

    def initialize
      @run_worker = false
    end

    def storage=( storage )

      storage = case storage
      when :transient
        Ruote::HashStorage.new
      when :file_system
        require 'ruote/storage/fs_storage'
        Ruote::FsStorage.new( File.join( Dir.pwd, "work_#{RuoteKit.env}" ) )
      else
        storage
      end

      @storage = storage
    end

    def storage
      @storage || (storage = :file_system)
    end

    def register( &block )
      @registration_block = block
    end

    protected

    def do_register
      ParticipantRegistrationProxy.instance_eval(
        &@registration_block
      ) if @registration_block
    end
  end
end
