
# Dependencies for ruote-kit

source :gemcutter

# ruote-kit itself

gem 'bundler'
gem 'sinatra'
gem 'sinatra-respond_to'
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

#gem 'ruote', '>= 2.1.11'
gem 'ruote', :git => 'git://github.com/jmettraux/ruote.git', :branch => 'ruote2.1'
#gem 'ruote', :path => '~/w/ruote/'

# Testing environment requirements

group :test do
  gem 'rspec', :require => "spec"
  gem 'rack-test'
  gem 'webrat'
  gem 'test-unit', '~> 1.2.3'
end

group :build do
  gem 'jeweler'
end

