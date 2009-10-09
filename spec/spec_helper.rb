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

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def app
  RuoteKit.sinatra
end
