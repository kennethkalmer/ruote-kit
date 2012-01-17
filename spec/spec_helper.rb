
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


SPEC_ROOT = File.expand_path('..', __FILE__) unless defined?(SPEC_ROOT)

require File.join(SPEC_ROOT, '../lib/ruote-kit')

Dir[File.join(SPEC_ROOT, 'support/**/*.rb')].each { |f| require(f) }


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
  config.include LinkHelper

  RuoteKit::Application.included_modules.each do |klass|
    config.include(klass) if klass.name =~ /RuoteKit::Helpers::\w+Helpers/
  end
end

