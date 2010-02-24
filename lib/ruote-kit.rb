require 'json'
require 'ruote'
require 'ruote/part/storage_participant'

module RuoteKit

  VERSION = '2.1.7'

  autoload :Configuration, "ruote-kit/configuration"
  autoload :Application,   "ruote-kit/application"
  autoload :Helpers,       "ruote-kit/helpers"

  class << self
    # The instance of ruote
    attr_accessor :engine

    # The instance of our worker, if used
    attr_accessor :worker

    def env
      @env ||= (
        if defined?( Rails )
          Rails.env
        else
          ENV['RACK_ENV'] || 'development'
        end
      )
    end

    # Yields a RuoteKit::Configuration instance and then immediately starts
    # the engine (unless configuration prohibits it).
    def configure( &block )
      yield configuration

      run_engine!
    end

    # Configure and run the engine in a RESTful container
    def run!( &block )
      yield if block_given?

      run_engine!
    end

    def shutdown!( purge_engine = false )
      shutdown_engine( purge_engine )
    end

    def configuration

      @configuration ||= Configuration.new
    end

    def configure_catchall!
      self.engine.register_participant('.*', configuration.catchall_participant)
    end

    def catchall_configured?
      !self.engine.context.plist.lookup('.*').nil?
    end

    # Ensure the engine is running
    def ensure_engine!
      run_engine! if self.engine.nil?
    end

    # Runs an engine, and starts a threaded workers if #configuration allows
    # it
    def run_engine!

      return unless configuration.run_engine

      storage = configuration.storage_instance
      self.engine = Ruote::Engine.new( storage )

      @storage_participant = nil

      run_worker!( true ) if configuration.run_worker
    end

    # Run a single worker. By default this method will block indefinitely,
    # unless +run_in_thread+ is set to true
    def run_worker!( run_in_thread = false )
      self.worker = Ruote::Worker.new( configuration.storage_instance )
      run_in_thread ? self.worker.run_in_thread : self.worker.run
    end

    def shutdown_engine( purge = false )

      return if self.engine.nil?

      self.engine.shutdown

      if purge
        self.engine.context.keys.each do |k|
          s = self.engine.context[k]
          s.purge if s.respond_to?(:purge)
        end
      end

      self.engine = nil

      shutdown_worker! if configuration.run_worker
    end

    def shutdown_worker!
      self.worker.shutdown if self.worker
      self.worker = nil
    end

    def storage_participant
      return nil if self.engine.nil?
      @storage_participant ||= Ruote::StorageParticipant.new(self.engine)
    end

    # resets the configuration
    #
    # mainly used in tests
    def reset_configuration!
      @configuration = nil
    end

  end
end
