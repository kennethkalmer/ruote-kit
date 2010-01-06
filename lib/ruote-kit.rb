require 'json'
require 'ruote'

module RuoteKit

  VERSION = "0.0.0"

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

    def root
      Dir.pwd
    end

    def configure( &block )
      configuration.instance_eval &block

      run_engine! if configuration.run_engine
    end

    # Configure and run the engine in a RESTful container
    def run!(&block)
      yield if block_given?

      run_engine!
    end

    def shutdown!( purge_engine = false )
      shutdown_engine( purge_engine )
    end

    def configuration

      @configuration ||= Configuration.new
    end

    def configure_participants
      self.engine.register_participant('.*', configuration.catchall_participant)
    end

    def ensure_engine!
      run_engine! if self.engine.nil?
    end

    def run_engine!

      storage = configuration.storage_instance
      self.engine = Ruote::Engine.new( storage )

      configure_participants

      return unless configuration.run_worker

      self.worker = Ruote::Worker.new( storage )
      self.worker.run_in_thread
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

      self.worker.shutdown if self.worker
      self.worker = nil
    end

  end
end
