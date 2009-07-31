begin
  require 'rack'
rescue LoadError
  puts "'rack' could not be loaded."
  exit 1
end

if Rack.version < "1.0"
  puts "Expecting rack 1.0 or later."
  exit 1
end
