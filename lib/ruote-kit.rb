
# license is MIT, see LICENSE.txt

require 'ostruct'

require 'rufus-json'
require 'ruote'
require 'ruote-kit/core_ext'
require 'ruote-kit/version'


module RuoteKit

  autoload :Application, 'ruote-kit/application'

  class << self

    attr_accessor :engine

    # RuoteKit.engine or RuoteKit.dashboard, whichever you prefer.
    #
    alias dashboard engine

    def env
      @env ||= defined?(Rails) ? Rails.env : ENV['RACK_ENV'] || 'development'
    end

    # Returns the storage participant associated automatically with any storage
    #
    def storage_participant
      engine.storage_participant
    end

    # RuoteKit.storage_participant or RuoteKit.worklist
    # (or RuoteKit.engine.storage_participant) whichever you prefer.
    #
    alias worklist storage_participant

    # Given a storage, runs a worker and sets RuoteKit.engine accordingly.
    #
    # By default, this method won't return (it will 'join' the worker). If you
    # need to go on after this call, pass false as second parameter
    # (especially useful in an EventMachine setting).
    #
    def run_worker(storage, join=true)
      RuoteKit.engine = Ruote::Dashboard.new(Ruote::Worker.new(storage))
      RuoteKit.engine.join if join
    end

    # Uses the given storage for the RuoteKit.engine (no worker running here).
    #
    def bind_engine(storage)
      RuoteKit.engine = Ruote::Dashboard.new(storage)
    end
  end
end

