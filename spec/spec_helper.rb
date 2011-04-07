
HERE = File.dirname(__FILE__) unless defined?(HERE)

ENV['RACK_ENV'] = 'test'

require 'rspec'
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

require File.join(HERE, '../lib/ruote-kit')
require 'ruote/log/test_logger'

Dir[File.join(HERE, 'support/**/*.rb')].each { |f| require(f) }


RSpec.configure do |config|

  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.include Webrat::Matchers
  config.include Rack::Test::Methods

  config.include RenderHelper
  config.include EngineHelper

  RuoteKit::Application.included_modules.each do |klass|
    config.include(klass) if klass.name =~ /RuoteKit::Helpers::\w+Helpers/
  end
end

