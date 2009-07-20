# Sets up the DaemonKit environment for Cucumber
ENV["DAEMON_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'daemon_kit/cucumber/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

DaemonKit::Application.running!
require 'ruote-kit'

Before '@delayedboot' do
  @_noboot = true
end

Before do
  RuoteKit.run! unless @_noboot
  @_noboot = nil
end

After do |scenario|
  # Shutdown
  RuoteKit.shutdown!( true ) if RuoteKit.engine
end
