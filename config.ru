
# bundler

require 'rubygems'
require 'bundler/setup'


# json
#
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


# ruote-kit

$:.unshift 'lib'
require 'ruote-kit'


# ruote

require 'ruote/storage/fs_storage'

RuoteKit.engine = Ruote::Engine.new(
  Ruote::Worker.new(
    Ruote::FsStorage.new(
      "ruote_work_#{RuoteKit.env}")))

RuoteKit.engine.register do
  catchall
end


# redirecting / to /_ruote (to avoid issue reports from new users)

class ToRuote
  def initialize(app)
    @app = app
  end
  def call(env)
    if env['PATH_INFO'] == '/'
      [ 303, { 'Location' => '/_ruote', 'Content-Type' => 'text/plain' }, [] ]
    else
      @app.call(env)
    end
  end
end

# rack middlewares, business as usual...

use ToRuote

use Rack::CommonLogger
use Rack::Lint
use Rack::ShowExceptions

run RuoteKit::Application

