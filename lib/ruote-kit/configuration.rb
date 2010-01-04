module RuoteKit
  # RuoteKit configuration handling
  class Configuration

    attr_accessor :rack_handler

    attr_accessor :rack_options

    # Path the access log for Rack::CommonLogger
    attr_accessor :access_log

    # Working directory for the engine (if using file system persistence)
    attr_accessor :work_directory

    # Number of workers to spawn (1 by default)
    attr_accessor :workers

    class << self

      # Default rack handlers to make use of
      def fallback_handlers
        @fallback_handlers ||= [ 'thin', 'webrick' ]
      end

    end

    def initialize
      self.rack_handler = :thin

      self.rack_options = {
        :port => 9292
      }

      self.work_directory = File.join( DaemonKit.root, "work_#{DaemonKit.env}" )

      self.workers = 1
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

    # Path to user-specific configuration
    def user_file
      File.join( DaemonKit.root, 'config', 'ruote.rb' )
    end

    # Return the best suited storage class for the current mode
    def storage_instance
      case mode
      when :transient
        require 'ruote/storage/hash_storage'
        Ruote::HashStorage.new
      when :file_system
        require 'ruote/storage/fs_storage'
        Ruote::FsStorage.new( self.work_directory )
      end
    end

    def catchall_participant
      require 'ruote/part/storage_participant'
      Ruote::StorageParticipant
    end

    def rack_handler_class
      begin
        Rack::Handler.get( self.rack_handler.to_s )
      rescue NameError
        unless self.class.fallback_handlers.empty?
          self.rack_handler = self.class.fallback_handlers.shift
          retry
        end
      end
    end
  end
end
