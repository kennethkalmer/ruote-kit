# Load ruote 2.0 from vendor
if File.directory?( DaemonKit.root + '/vendor/ruote' )
  $:.unshift( DaemonKit.root + '/vendor/ruote/lib' )
else
  puts <<EOF

Expecting vendor/ruote to exist!

ruote-kit expects a copy of the ruote master branch
(git://github.com/jmettraux/ruote) to exist in the
#{DaemonKit.root}/vendor/ruote directory. You can safely
symlink the code from somewhere else on your system, or
clone the directory directly into vendor/.

ruote-kit is now terminating.

EOF
  exit 1
end

require 'ruote/engine'

if !defined?( Ruote )
  puts "Expecting ruote 2.0.0 or later"
  puts "Need to exit here..."
  exit 1
end
