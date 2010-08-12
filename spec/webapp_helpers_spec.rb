
require File.join(File.dirname(__FILE__), 'spec_helper.rb')


describe RuoteKit::Helpers::RenderHelpers do

  describe 'alink()' do

    it 'link to top resources' do

      alink(:processes).should ==
        '<a href="/_ruote/processes" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes">/_ruote/processes</a>'
    end

    it 'should link to identified resources' do

      alink(:processes, '20120808-tokushima').should ==
        '<a href="/_ruote/processes/20120808-tokushima" rel="http://ruote.rubyforge.org/rels.html#process" title="/_ruote/processes/20120808-tokushima">/_ruote/processes/20120808-tokushima</a>'
    end

    it 'should accept a custom :text' do

      alink(:processes, :text => 'processes').should ==
        '<a href="/_ruote/processes" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes">processes</a>'
    end

    it 'should aggregate non-:text options into the query string' do

      alink(:processes, :skip => 3, :limit => 4).should ==
        '<a href="/_ruote/processes?limit=4&skip=3" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes?limit=4&skip=3">/_ruote/processes?limit=4&skip=3</a>'
    end

    it 'should accept a custom :rel' do

      alink(:processes, :rel => 'last').should ==
        '<a href="/_ruote/processes" rel="last" title="/_ruote/processes">/_ruote/processes</a>'
    end

    it 'should accept a :head id for processes, errors, schedules and workitems' do

      self.instance_eval do
        def settings; OpenStruct.new(:limit => 100); end
      end
        # tricking the helper...

      alink(:processes, :head, :text => 'processes').should ==
        '<a href="/_ruote/processes?limit=100&skip=0" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes?limit=100&skip=0">processes</a>'
    end
  end
end

