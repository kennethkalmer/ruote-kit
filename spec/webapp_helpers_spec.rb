
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

  describe 'links(resource) (JSON)' do

    before(:each) do

      @resource = Object.new
      class << @resource
        include RuoteKit::Helpers::LinkHelpers
        include RuoteKit::Helpers::JsonHelpers
        attr_accessor :processes, :count, :skip, :limit, :request
        def settings
          OpenStruct.new(:limit => @limit)
        end
      end
      @resource.request = OpenStruct.new(:fullpath => '/_ruote/processes')
    end

    it 'should paginate correctly' do

      @resource.processes = (1..201).to_a
      @resource.count = @resource.processes.size

      @resource.skip = 5
      @resource.limit = 5

      @resource.links(:processes)[8..-1].should == [
        { 'href' => '/_ruote/processes',
          'rel' => 'all' },
        { 'href' => '/_ruote/processes?limit=5&skip=0',
          'rel' => 'first' },
        { 'href' => '/_ruote/processes?limit=5&skip=200',
          'rel' => 'last' },
        { 'href' => '/_ruote/processes?limit=5&skip=0',
          'rel' => 'previous' },
        { 'href' => '/_ruote/processes?limit=5&skip=10',
          'rel' => 'next' }
      ]
    end
  end

  describe '_pagination.html.haml (HTML)' do

    before(:each) do
      @resource = Object.new
      class << @resource
        attr_accessor :count, :skip, :limit, :request
        def to_html
          '<div>' + render('_pagination.html.haml', self) + '</div>'
        end
        def settings
          OpenStruct.new(:limit => @limit)
        end
      end
      @resource.request = OpenStruct.new(:path => '/_ruote/processes')
    end

    it 'should paginate correctly' do

      @resource.count = 201
      @resource.skip = 0
      @resource.limit = 7

      html = @resource.to_html

      html.index("  1\n  to\n  7\n  of\n  201\n  processes").should > 0

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'previous')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=7', :rel => 'next')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end
  end
end

