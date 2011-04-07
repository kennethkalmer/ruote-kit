
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    # Helpers about links
    #
    module LinkHelpers

      # Computes the path to the JSON alternate version
      # of the current request uri, used by the the "as_json
      # link at the bottom of each page.
      #
      # Returns the String path.
      def as_json

        href = request.path + '.json'

        if request.query_string.length > 0
          href = "#{href}?#{request.query_string}"
        end

        href
      end

      # Determining { 'href' => 'x', 'rel' => 'y', ... } and co
      #
      def hlink(*args)

        query = args.last.is_a?(Hash) ? args.pop : {}
        query = query.reject { |k, v| k == :text }

        args = args.collect { |arg| arg.to_s }

        if args.last == 'head'
          args.pop
          query[:skip] = 0
          query[:limit] = settings.limit
        end

        rel   = query.delete(:rel) || compute_rel(args)
        title = query.delete(:title)

        query = Rack::Utils.build_query(query.sort)
        query = "?#{query}" if !query.empty?

        if args.empty? or ( ! args.first.match(/^\/\_ruote/))
          args.unshift('/_ruote')
        end
        href = args.join('/')

        href = url("#{href}#{query}", false)

        result = {
          'href' => href,
          'rel'  => rel.match(/^#/) ?
            "http://ruote.rubyforge.org/rels.html#{rel}" : rel,
        }

        if title
          result['title'] = title == true ? href : title
        end

        result
      end

      # Returns an <a href="x" rel="y">z</a>, uses #hlink.
      #
      def alink(*args)

        args << {} unless args.last.is_a?(Hash)
        args.last[:title] = true

        opts = args.last

        hl = hlink(*args)

        attributes = %w[ href rel title ].inject([]) { |a, att|
          if val = hl[att]
            a << "#{att}=\"#{val}\""
          end
          a
        }.join(' ')

        "<a #{attributes}>#{opts[:text] || hl['href']}</a>"
      end

      protected

      def compute_rel(args)

        wfid, fei = if ( ! args[1])
          [ false, false ]
        elsif args[1].index('!')
          [ false, true ]
        else
          [ true, false ]
        end

        case args.first
          when 'processes'
            wfid ? '#process' : '#processes'
          when 'expressions'
            fei ? '#expression' : '#process_expressions'
          when 'errors'
            fei ? '#error' : '#process_errors'
          when 'workitems'
            fei ? '#workitem' : '#process_workitems'
          when 'schedules'
            wfid ? '#process_schedules' : '#schedules'
          else
            ''
        end
      end
    end
  end
end

