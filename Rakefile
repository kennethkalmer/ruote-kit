
require 'rake/tasklib'

require "rubygems"
require "bundler"
Bundler.setup(:default, :test, :build)

require File.join(File.dirname(__FILE__), 'lib/ruote-kit/version')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'ruote-kit'
    gemspec.version = RuoteKit::VERSION
    gemspec.summary = 'ruote workflow engine, wrapped in a loving rack embrace'
    gemspec.description = 'ruote-kit is a RESTful Rack app for the ruote workflow engine'
    gemspec.email = 'kenneth.kalmer@gmail.com'
    gemspec.homepage = 'http://github.com/tosch/ruote-kit'
    gemspec.authors = [ 'kenneth.kalmer@gmail.com', 'Torsten Schoenebaum', 'John Mettraux' ]
    gemspec.extra_rdoc_files.include '*.txt'

    gemspec.files.include 'lib/ruote-kit/public/**/*'
    gemspec.executables.clear

    gemspec.add_bundler_dependencies
    gemspec.files.exclude 'rails-template.rb'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with 'gem install jeweler'"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec #=> :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
