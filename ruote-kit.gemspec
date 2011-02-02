# encoding: utf-8

require 'bundler'
  # for #add_bundler_dependencies

Gem::Specification.new do |s|

  s.name = 'ruote-kit'
  s.version = File.read('lib/ruote-kit/version.rb').match(/VERSION = '([^']+)'/)[1]
  s.platform = Gem::Platform::RUBY
  s.authors = [ 'Kenneth kalmer', 'Torsten Schoenebaum', 'John Mettraux' ]
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
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ] - [ 'rails-template.rb' ]

  s.add_bundler_dependencies

  #s.require_path = 'lib'
end

