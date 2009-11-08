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
require 'ruote/log/test_logger'

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

  config.before(:each) do
    @tracer = Tracer.new
    RuoteKit.engine.context[:s_tracer] = @tracer
    RuoteKit.engine.add_service(:s_logger, Ruote::TestLogger)
  end

  # Purge the engine after every run
  config.after(:each) do
    RuoteKit.engine.plist.lookup('.*').purge!
    RuoteKit.engine.purge!
  end
end

def app
  RuoteKit.sinatra
end

# Sets the local variables that will be accessible in the HAML
# template
def assigns
  @assigns ||= { }
end

class Rack::MockResponse
  def json_body
    Ruote::Json.decode( body )
  end
end


class Tracer
  def initialize
    @trace = ''
  end
  def to_s
    @trace.to_s.strip
  end
  def << s
    @trace << s
  end
  def clear
    @trace = ''
  end
  def puts s
    @trace << "#{s}\n"
  end
end
