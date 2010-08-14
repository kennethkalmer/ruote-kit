
ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'spec'
require 'spec/interop/test'
require 'rack/test'

require 'webrat'

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

Test::Unit::TestCase.send :include, Rack::Test::Methods

begin
  require File.join(File.dirname(__FILE__), '/../vendor/gems/environment')
rescue LoadError
end
require File.join(File.dirname(__FILE__), '/../lib/ruote-kit')

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
    config.include(klass) if klass.name =~ /RuoteKit::Helpers::\w+Helpers/
  end
end

def app
  RuoteKit::Application
end

def render(template, scope=nil, locals={}, &block)
  template = File.read(File.join(app.views, template.to_s))
  engine = Haml::Engine.new(template)
  engine.render(scope, locals, &block)
end

class Rack::MockResponse

  def json_body
    Rufus::Json.decode(body)
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

