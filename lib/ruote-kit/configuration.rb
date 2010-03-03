module RuoteKit
  # RuoteKit configuration handling
  class Configuration

    class ParticipantRegistrationProxy
      def self.participant(*args, &block)
        RuoteKit.engine.register_participant(*args, &block)
      end
      
      def self.catchall(*args, &block)
        if(args.empty? and not block_given?)
          require 'ruote/part/storage_participant'
          participant('.+', Ruote::StorageParticipant)
        else
          participant('.+', *args, &block)
        end
      end
    end

    # Working directory for the engine (if using file system persistence)
    attr_accessor :work_directory

    # Number of workers to spawn (1 by default)
    attr_accessor :workers

    # Whether to run the engine or not (defaults to true)
    attr_accessor :run_engine

    # Whether to run a single worker or not (defaults to false)
    attr_accessor :run_worker

    def initialize
      self.work_directory = File.join( Dir.pwd, "work_#{RuoteKit.env}" )
      self.run_engine = true
      self.run_worker = false
    end

    # Return the selected ruote-kit mode
    def mode
      @mode ||= :file_system
    end

    # Set the ruote-kit mode
    def mode=( mode )
      raise ArgumentError, "Unsupported mode (#{mode})" unless [ :transient, :file_system ].include?( mode )
      @mode = mode
    end

    # Sets a custom storage
    def set_storage( klass, *args )
      @storage = [ klass, args ]
      @mode = :custom
    end

    # Return the best suited storage class for the current mode
    def storage_instance

      if @storage
        klass, args = @storage
        return klass.new( *args )
      end

      case mode
      when :transient
        require 'ruote/storage/hash_storage'
        Ruote::HashStorage.new
      when :file_system
        require 'ruote/storage/fs_storage'
        Ruote::FsStorage.new( self.work_directory )
      end
    end

    def register &block
      @participant_registration_block = block
      do_participant_registration
    end

    def do_participant_registration
      return nil unless @participant_registration_block && RuoteKit.engine
      ParticipantRegistrationProxy.instance_eval(&@participant_registration_block)
    end
  end
end
