Given /^ruote\-kit has booted$/ do
  RuoteKit.run! if RuoteKit.engine.nil?
end

Then /^ruote\-kit should have a logger$/ do
  DaemonKit.logger.should_not be_nil
end

Then /^ruote\-kit should have a engine$/ do
  RuoteKit.engine.should_not be_nil
end

Given /^ruote\-kit is configured to use "([^\"]*)" mode$/ do |mode|
  mode = mode.gsub(/[^\w]/, '_').downcase.to_sym

  pending if mode == :active_record

  RuoteKit.configuration.mode = mode
end

Then /^the engine should be using "([^\"]*)" persistence$/ do |engine_type|
  engine_class = case engine_type.downcase
    when "no"
      "Ruote::Engine"
    when "file system"
      "Ruote::FsPersistedEngine"
    end

  RuoteKit.engine.class.to_s.should == engine_class
end

Then /^the engine should have a "([^\"]*)" "([^\"]*)" participant$/ do |name, ptype|
  #require 'ruby-debug'; debugger
  name = ".*" if name == "wild card"

  part = RuoteKit.engine.plist.lookup( name )
  part.should_not be_nil

  part.class.to_s.should match(/#{ptype}/i)
end
