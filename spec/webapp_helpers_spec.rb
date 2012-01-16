
require 'spec_helper'


describe RuoteKit::Helpers::RenderHelpers do

  describe 'alink()' do

    it 'links to top resources' do

      alink(:processes).should ==
        '<a href="/_ruote/processes" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes">/_ruote/processes</a>'
    end

    it 'links to identified resources' do

      alink(:processes, '20120808-tokushima').should ==
        '<a href="/_ruote/processes/20120808-tokushima" rel="http://ruote.rubyforge.org/rels.html#process" title="/_ruote/processes/20120808-tokushima">/_ruote/processes/20120808-tokushima</a>'
    end

    it 'accepts a custom :text' do

      alink(:processes, :text => 'processes').should ==
        '<a href="/_ruote/processes" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes">processes</a>'
    end

    it 'aggregates non-:text options into the query string' do

      alink(:processes, :skip => 3, :limit => 4).should ==
        '<a href="/_ruote/processes?limit=4&skip=3" rel="http://ruote.rubyforge.org/rels.html#processes" title="/_ruote/processes?limit=4&skip=3">/_ruote/processes?limit=4&skip=3</a>'
    end

    it 'accepts a custom :rel' do

      alink(:processes, :rel => 'last').should ==
        '<a href="/_ruote/processes" rel="last" title="/_ruote/processes">/_ruote/processes</a>'
    end

    it 'accepts a :head id for processes, errors, schedules and workitems' do

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
        include Sinatra::Helpers

        attr_accessor :processes, :count, :skip, :limit, :request

        def settings
          OpenStruct.new(:limit => @limit)
        end
      end
      @resource.request = OpenStruct.new(:fullpath => '/_ruote/processes')
    end

    it 'paginates correctly' do

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
        include RenderHelper
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

    it 'paginates correctly (1st page)' do

      @resource.count = 201
      @resource.skip = 0
      @resource.limit = 7

      html = @resource.to_html

      html.index("  1\n  to\n  7\n  of\n  201\n  processes").should > 0

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'previous')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=7', :rel => 'next')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end

    it 'paginates correctly (2nd page)' do

      @resource.count = 201
      @resource.skip = 7
      @resource.limit = 7

      html = @resource.to_html

      html.index("  8\n  to\n  14\n  of\n  201\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'previous')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=14', :rel => 'next')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end

    it 'paginates correctly (3rd page)' do

      @resource.count = 201
      @resource.skip = 14
      @resource.limit = 7

      html = @resource.to_html

      html.index("  15\n  to\n  21\n  of\n  201\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=7', :rel => 'previous')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=21', :rel => 'next')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end

    it 'paginates correctly (right before last page)' do

      @resource.count = 201
      @resource.skip = 189
      @resource.limit = 7

      html = @resource.to_html

      html.index("  190\n  to\n  196\n  of\n  201\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=182', :rel => 'previous')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=21', :rel => 'next')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end

    it 'paginates correctly (last page)' do

      @resource.count = 201
      @resource.skip = 196
      @resource.limit = 7

      html = @resource.to_html

      html.index("  197\n  to\n  201\n  of\n  201\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=0', :rel => 'first')
      html.should have_selector(
        'a', :href => '/_ruote/processes?limit=7&skip=189', :rel => 'previous')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=21', :rel => 'next')
      #html.should have_selector(
      #  'a', :href => '/_ruote/processes?limit=7&skip=196', :rel => 'last')
    end

    it 'paginates correctly (corner case 3 items, limit 3)' do

      @resource.count = 3
      @resource.skip  = 0
      @resource.limit = 3

      html = @resource.to_html

      html.index("  1\n  to\n  3\n  of\n  3\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should_not have_selector(
        'a', :rel => 'first')
      html.should_not have_selector(
        'a', :rel => 'previous')
      html.should_not have_selector(
        'a', :rel => 'next')
      html.should_not have_selector(
        'a', :rel => 'last')
    end

    it 'paginates correctly (corner case 30 items, limit 10, skip 20)' do

      @resource.count = 30
      @resource.skip  = 20
      @resource.limit = 10

      html = @resource.to_html

      html.should_not have_selector(
        'a', :rel => 'next')
      html.should_not have_selector(
        'a', :rel => 'last')
    end

    it 'does not show there is an item if there is none' do

      @resource.count = 0
      @resource.skip  = 0
      @resource.limit = 100

      html = @resource.to_html

      html.index("  0\n  to\n  0\n  of\n  0\n  processes").should_not be(nil)

      html.should have_selector(
        'a', :href => '/_ruote/processes', :rel => 'all')
      html.should_not have_selector(
        'a', :rel => 'first')
      html.should_not have_selector(
        'a', :rel => 'previous')
      html.should_not have_selector(
        'a', :rel => 'next')
      html.should_not have_selector(
        'a', :rel => 'last')
    end

    it 'ignores negative values for skip param' do

      @resource.count = 10
      @resource.skip  = -5
      @resource.limit = 100

      html = @resource.to_html

      html.index("  1\n  to\n  10\n  of\n  10\n  processes").should_not be(nil)

      # perhaps a redirection to the same url but with a sane param would be
      # more appropriate?
    end

    it 'ignores values for the skip param larger than the number of items' do

      @resource.count = 10
      @resource.skip  = 20
      @resource.limit = 5

      html = @resource.to_html

      html.index("  6\n  to\n  10\n  of\n  10\n  processes").should_not be(nil)

      # perhaps a redirection to the same url but with a sane param would be
      # more appropriate?
    end
  end

  private

  # Simulates Sinatra::Helpers#uri.
  def uri(addr = nil, absolute = true, add_script_name = true)
    addr
  end
  alias :url :uri
  alias :to :uri
end

