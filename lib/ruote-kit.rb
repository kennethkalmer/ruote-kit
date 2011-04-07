
# license is MIT, see LICENSE.txt

require 'ostruct'

require 'rufus-json'
require 'ruote'
require 'ruote/part/storage_participant'
require 'ruote-kit/core_ext'
require 'ruote-kit/version'


module RuoteKit

  autoload :Application, 'ruote-kit/application'

  class << self

    attr_accessor :engine

    def env
      @env ||= defined?(Rails) ? Rails.env : ENV['RACK_ENV'] || 'development'
    end

    # Returns the storage participant associated automatically with any storage
    #
    def storage_participant
      engine.storage_participant
    end

    # Given a storage, runs a worker and sets RuoteKit.engine accordingly.
    #
    # By default, this method won't return (it will 'join' the worker). If you
    # need to go on after this call, pass false as second parameter
    # (especially useful in an EventMachine setting).
    #
    def run_worker(storage, join=true)
      RuoteKit.engine = Ruote::Engine.new(
        Ruote::Worker.new(storage), :join => join)
    end

    # Uses the given storage for the RuoteKit.engine (no worker running here).
    #
    def bind_engine(storage)
      RuoteKit.engine = Ruote::Engine.new(storage)
    end
  end
end

