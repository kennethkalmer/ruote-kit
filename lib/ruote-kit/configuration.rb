module RuoteKit
  # RuoteKit configuration handling
  class Configuration

    attr_accessor :rack_handler

    attr_accessor :rack_options

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

    # Return the best suited engine class for the current mode
    def engine_class
      case mode
      when :transient
        Ruote::Engine
      when :file_system
        require 'ruote/engine/fs_engine'
        Ruote::FsPersistedEngine
      end
    end

    # Return the best suited 'catchall' participant class for the current mode
    def catchall_participant
      case mode
      when :transient
        require 'ruote/part/hash_participant'
        Ruote::HashParticipant
      when :file_system
        require 'ruote/part/fs_participant'
        Ruote::FsParticipant
      end
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
