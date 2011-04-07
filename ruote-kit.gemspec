# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "ruote-kit/version"

Gem::Specification.new do |s|

  s.name = 'ruote-kit'
  s.version = RuoteKit::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = [ 'Kenneth Kalmer', 'Torsten Schoenebaum', 'John Mettraux' ]
  s.email = [ 'kenneth.kalmer@gmail.com' ]
  s.homepage = 'http://github.com/tosch/ruote-kit'
  s.rubyforge_project = 'ruote'
  s.summary = 'ruote workflow engine, wrapped in a loving rack embrace'
  s.description = %q{
ruote workflow engine, wrapped in a loving rack embrace
}

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Rakefile',
    'lib/**/*.rb', 'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md',
    'lib/ruote-kit/public/**/*', 'lib/ruote-kit/views/**/*'
  ] - [ 'rails-template.rb' ]

  s.add_runtime_dependency 'sinatra', '~> 1.2.0'
  s.add_runtime_dependency 'sinatra-respond_to', '~> 0.7.0'
  s.add_runtime_dependency 'haml', '3.0.25'

  s.add_runtime_dependency 'rufus-json', '>= 0.2.5'
  #s.add_runtime_dependency('ruote', s.version) unless defined?(Bundler)
  s.add_runtime_dependency('ruote', '>= 2.2.0') unless defined?(Bundler)
    # see Gemfile

  s.add_development_dependency 'rspec', '~> 2.5.0'
  s.add_development_dependency 'rack-test', '0.5.7'
  s.add_development_dependency 'webrat', '0.7.3'

  s.require_path = 'lib'
end

