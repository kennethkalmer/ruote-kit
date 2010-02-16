begin
  # Try to require the preresolved locked set of gems.
  require ::File.expand_path('.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

$:.unshift 'lib'

require 'lib/ruote-kit'

# Chance to configure ruote-kit
RuoteKit.configure do |config|
  
  # storage mode
  #config.mode = :transient

  # run a worker
  config.run_worker = true
end

# With this rackup I bundle as catchall, making it easy to experiment
RuoteKit.configure_catchall!

use Rack::CommonLogger
use Rack::Lint
use Rack::ShowExceptions

run RuoteKit::Application
