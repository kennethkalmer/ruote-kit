
begin
  # try to require the preresolved locked set of gems.
  require ::File.expand_path( '.bundle/environment', __FILE__ )
rescue LoadError
  # fall back on doing an unlocked resolve at runtime.
  require 'rubygems'
  require 'bundler'
  Bundler.setup( :default )
end

# load json support
# try yajl-ruby first, and json after that
begin
  require 'yajl'
rescue LoadError
  begin
    require 'json'
  rescue LoadError
    puts 'Please specify "gem {yajl-ruby|json_pure|json}" in the Gemfile'
    exit
  end
end

require 'rufus-json'

$:.unshift 'lib'

require 'ruote-kit'

# chance to configure ruote-kit
RuoteKit.configure do |config|

  # storage mode
  #config.mode = :transient

  # run a worker
  config.run_worker = true

  config.register do

    # each file .rb in that dir is supposed to contain a participant
    # implementation (the name of the participant is the filename (minus
    # the extension))
    from_dir './participants'

    # with this rackup I bundle as catchall, making it easy to experiment
    catchall
  end
end


use Rack::CommonLogger
use Rack::Lint
use Rack::ShowExceptions

run RuoteKit::Application

