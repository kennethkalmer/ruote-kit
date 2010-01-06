require 'vendor/gems/environment' if ::File.exist?( 'vendor/gems/environment.rb' )

$:.unshift 'lib'

require 'lib/ruote-kit'

# Chance to configure ruote-kit
RuoteKit.configure do |config|
  
  # storage mode
  #config.mode = :transient

  # run a worker
  config.run_worker = true
end

use Rack::CommonLogger
use Rack::Lint
use Rack::ShowExceptions

run RuoteKit::Application
