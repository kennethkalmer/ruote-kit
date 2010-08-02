
# bundler

begin
  # try to require the preresolved locked set of gems.
  require ::File.expand_path('.bundle/environment', __FILE__)
rescue LoadError
  # fall back on doing an unlocked resolve at runtime.
  require 'rubygems'
  require 'bundler'
  Bundler.setup(:default)
end


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


# rack middlewares, business as usual...

use Rack::CommonLogger
use Rack::Lint
use Rack::ShowExceptions

run RuoteKit::Application

