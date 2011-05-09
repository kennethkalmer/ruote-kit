
require 'spec_helper'

describe Symbol do

  describe "#<=>", :if => RUBY_VERSION < "1.9" do

    it "is defined" do
      :foo.should respond_to(:<=>)
    end

    it "compares self with other against their to_s representation" do
      (:foo <=> :bar).should == ("foo" <=> "bar")
      (:bar <=> :foo).should == ("bar" <=> "foo")
      (:foo <=> :foo).should == ("foo" <=> "foo")
    end
  end
end

