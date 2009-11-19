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

require 'webrat'

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
  config.include Webrat::Matchers, :type => :views
  config.include RuoteKit::Spec::RuoteHelpers

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

# Renders the supplied template with Haml::Engine and assigns the
# @response instance variable
def render(template_path)
  template = File.read("#{app.views}/#{template_path.sub(/^\//, '')}")
  engine = Haml::Engine.new(template)
  @response = engine.render(self, assigns_for_template)
end

# Convenience method to access the @response instance variable set in
# the render call
def response
  @response
end

# Sets the local variables that will be accessible in the HAML
# template
def assigns
  @assigns ||= { }
end

# Prepends the assigns keywords with an "@" so that they will be
# instance variables when the template is rendered.
def assigns_for_template
  assigns.inject({}) do |memo, kv|
    memo["@#{kv[0].to_s}".to_sym] = kv[1]
    memo
  end
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
