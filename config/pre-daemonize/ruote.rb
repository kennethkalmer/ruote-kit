# Load ruote 2.0 from vendor
if File.directory?( DaemonKit.root + '/vendor/ruote' )
  $:.unshift( DaemonKit.root + '/vendor/ruote/lib' )
else
  puts "Expecting vendor/ruote to exist"
  exit 1
end

require 'ruote/engine'

if !defined?( Ruote) #|| Ruote::VERSION < "2.0.0"
  puts "Expecting ruote 2.0.0 or later"
  puts "Need to exit here..."
  #exit 1
end
