Then /^ruote\-kit should have a rack$/ do
  RuoteKit.rack.should_not be_nil
end

Then /^ruote\-kit should have the "([^\"]*)" middleware loaded$/ do |klass|
  pending
  stack = RuoteKit.rack.instance_variable_get(:@ins)
  stack.map { |m| m.class.to_s }.should include(klass)
end

Then /^ruote\-kit should use the "([^\"]*)" rack handler$/ do |klass|
  pending "Mongrel not supported on 1.9 yet" if klass == "Mongrel" && RUBY_VERSION >= "1.9"

  RuoteKit.configuration.rack_handler_class.to_s.should == "Rack::Handler::#{klass}"
end

Given /^ruote\-kit is configured to use the "([^\"]*)" rack handler$/ do |handler|
  RuoteKit.configuration.rack_handler = handler.downcase
end

Given /^ruote\-kit is configured to use the "([^\"]*)" middleware$/ do |middleware|
  pending
end
