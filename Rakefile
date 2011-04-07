require 'rubygems'
require 'rubygems/user_interaction' if Gem::RubyGemsVersion == '1.5.0'
require 'bundler'

require 'rake'
require 'rake/clean'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks


#
# clean

CLEAN.include('pkg', 'rdoc')


#
# test / spec

RSpec::Core::RakeTask.new

task :test => :spec
task :default => :spec


#
# gem

GEMSPEC = Bundler.load_gemspec(Dir['*.gemspec'].first)


#
# rdoc
#
# make sure to have rdoc 2.5.x to run that

Rake::RDocTask.new do |rd|

  rd.main = 'README.rdoc'
  rd.rdoc_dir = 'rdoc'

  rd.rdoc_files.include(
    'README.rdoc', 'CHANGELOG.txt', 'CREDITS.txt', 'lib/**/*.rb')

  rd.title = "#{GEMSPEC.name} #{GEMSPEC.version}"
end


#
# upload_rdoc

desc %{
  upload the rdoc to rubyforge
}
task :upload_rdoc => [ :clean, :rdoc ] do

  account = 'jmettraux@rubyforge.org'
  webdir = '/var/www/gforge-projects/ruote'

  sh "rsync -azv -e ssh rdoc/#{GEMSPEC.name}_rdoc #{account}:#{webdir}/"
end

