
# Dependencies for ruote-kit

source :gemcutter

# ruote-kit itself

gem 'bundler'
gem 'sinatra', '1.0', :require => 'sinatra/base'
gem 'sinatra-respond_to', '0.5.0'
gem 'haml'

# more servers

gem 'thin'
  # for rackup -s thin

# json support
#
# you should choose one of the following three or add another backend supported
# by Rufus::Json (http://github.com/jmettraux/rufus-json/)
#
# gem 'json_pure'  # safest all-around choice
# gem 'yajl-ruby'  # the fastest, but using c code
# gem 'json'       # not bad, but using c code and sometimes broken
# gem 'json-jruby' # for jruby
#
# needed, uses one of the above as backend

gem 'yajl-ruby', :require => 'yajl'
gem 'rufus-json', '>= 0.2.5'

# ruote

#gem 'ruote', '~> 2.1.11'
gem 'ruote', :git => 'git://github.com/jmettraux/ruote.git'
#gem 'ruote', :path => '~/w/ruote/'

# Testing environment requirements

group :test do
  gem 'rspec', '~> 1.3.1', :require => "spec"
  gem 'rack-test'
  gem 'webrat'
  gem 'test-unit', '~> 1.2.3'
end

group :build do
  gem 'jeweler'
end

