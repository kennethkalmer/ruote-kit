ENV['DAEMON_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'spec/interop/test'
require 'rack/test'

Test::Unit::TestCase.send :include, Rack::Test::Methods

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!
RuoteKit.run!

require 'ruote-kit/spec/ruote_helpers'

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Include our helpers
  config.include( RuoteKit::Spec::RuoteHelpers )

  # Purge the engine after every run
  config.after(:each) do
    RuoteKit.engine.purge!
  end
end

def app
  RuoteKit.sinatra
end

class Rack::MockResponse
  def json_body
    Ruote::Json.decode( body )
  end
end
