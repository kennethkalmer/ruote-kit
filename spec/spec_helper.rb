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

require File.dirname(__FILE__) + '/../vendor/gems/environment' if File.exists?( File.dirname(__FILE__) + '/../vendor/gems/environment.rb' )
require File.dirname(__FILE__) + '/../lib/ruote-kit'

RuoteKit.configure do |config|

  # In memory is perfect for tests
  config.mode = :transient
end

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

  config.before(:each, :type => :with_engine) do
    RuoteKit.run_engine!
    RuoteKit.configure_catchall!

    @tracer = Tracer.new
    RuoteKit.engine.add_service( 'tracer', @tracer )

    # Specs use their own worker since we need the trace
    @_spec_worker = Ruote::Worker.new( RuoteKit.engine.storage )
    @_spec_worker.context.add_service( 'tracer', @tracer )
    @_spec_worker.run_in_thread
  end

  # Purge the engine after every run
  config.after(:each, :type => :with_engine) do
    @_spec_worker.shutdown

    # Seems in some rubies this block gets called multiple times
    unless RuoteKit.engine.nil?
      RuoteKit.storage_participant.purge!
      RuoteKit.engine.storage.purge! unless RuoteKit.engine.storage.nil?

      RuoteKit.shutdown_engine( true )
    end
  end

  RuoteKit::Application.included_modules.each do |klass|
    if klass.name =~ /RuoteKit::Helpers::\w+Helpers/
      config.include klass
    end
  end
end

def app
  RuoteKit::Application
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
    Rufus::Json.decode( body )
  end

  def json?
    begin
      json_body
      return true
    rescue
      return false
    end
  end

  def html?
    !json?
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
