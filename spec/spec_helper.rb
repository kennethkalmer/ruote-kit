
ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup( :default, :test )

require 'spec'
require 'spec/interop/test'
require 'rack/test'

require 'webrat'

require 'json'

Test::Unit::TestCase.send :include, Rack::Test::Methods

begin
  require File.join( File.dirname( __FILE__ ), '/../vendor/gems/environment' )
rescue LoadError
end
require File.join( File.dirname( __FILE__ ), '/../lib/ruote-kit' )

require 'ruote-kit/spec/ruote_helpers'
require 'spec/it_has_an_engine'

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

  def it_has_an_engine
    it_should_behave_like 'it has an engine'
  end
  def it_has_an_engine_with_no_participants
    it_should_behave_like 'it has an engine with no participants'
  end

  RuoteKit::Application.included_modules.each do |klass|
    config.include( klass ) if klass.name =~ /RuoteKit::Helpers::\w+Helpers/
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
  template = File.read( "#{app.views}/#{template_path.sub( /^\//, '' )}" )
  engine = Haml::Engine.new( template )
  @response = engine.render( self, assigns_for_template )
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
  assigns.inject( {} ) do |memo, kv|
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
    ! json?
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

