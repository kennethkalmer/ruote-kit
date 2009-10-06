begin
  require 'sinatra'
rescue LoadError
  require 'rubygems'
  require 'sinatra'
end
