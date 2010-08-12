
# license is MIT, see LICENSE.txt

require 'ostruct'

require 'rufus-json'
require 'ruote'
require 'ruote/part/storage_participant'
require 'ruote-kit/version'


module RuoteKit

  autoload :Application, 'ruote-kit/application'

  class << self

    attr_accessor :engine

    def env
      @env ||= defined?(Rails) ? Rails.env : ENV['RACK_ENV'] || 'development'
    end

    #def storage_participant
    #  engine.storage_participant
    #end

    def run_worker (storage)
      RuoteKit.engine = Ruote::Engine.new(Ruote::Worker.new(storage))
    end

    def bind_engine (storage)
      RuoteKit.engine = Ruote::Engine.new(storage)
    end
  end
end

