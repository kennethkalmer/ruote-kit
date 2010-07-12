
require 'rufus-json'
require 'ruote'
require 'ruote/part/storage_participant'
require 'ruote-kit/version'

module RuoteKit

  autoload :Configuration, 'ruote-kit/configuration'
  autoload :Application, 'ruote-kit/application'
  autoload :Helpers, 'ruote-kit/helpers'

  class << self

    # The instance of ruote
    attr_accessor :engine

    # The instance of our worker, if used
    attr_accessor :worker

    def env
      @env ||= defined?( Rails ) ? Rails.env : ENV['RACK_ENV'] || 'development'
    end

    # Yields a RuoteKit::Configuration instance and then immediately starts
    # the engine.
    def configure
      yield( configuration ) if block_given?
      instantiate_engine
    end

    def shutdown!( purge_engine = false )
      shutdown_engine( purge_engine )
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def instantiate_engine

      storage = configuration.storage

      self.engine = Ruote::Engine.new(
        configuration.run_worker ? Ruote::Worker.new(storage) : storage)

      configuration.send(:do_register)
    end

    ## Run a single worker. By default this method will block indefinitely,
    ## unless +run_in_thread+ is set to true
    #def run_worker!( run_in_thread = false )
    #  self.worker = Ruote::Worker.new( configuration.storage_instance )
    #  run_in_thread ? self.worker.run_in_thread : self.worker.run
    #end

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
      @storage_participant ||= (engine ? engine.storage_participant : nil)
    end
  end
end

