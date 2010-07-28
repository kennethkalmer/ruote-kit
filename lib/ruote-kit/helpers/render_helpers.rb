
module RuoteKit
  module Helpers

    # Helpers for rendering stuff
    #
    module RenderHelpers

      def alink( *args )

        opts = args.last.is_a?(Hash) ? args.pop : {}

        args = args.collect { |a| a.to_s }

        resource = args.first
        path = args.join('/')
        href = "/_ruote/#{path}"
        rel = if resource == 'process'
          '#process'
        elsif resource == 'expressions'
          args.length == 2 ? '#process_expressions' : '#expression'
        elsif resource == 'errors'
          args.length == 2 ? '#process_errors' : '#errors'
        else
          ''
        end
        rel = "http://ruote.rubyforge.org/rels.html#{rel}" if rel.length > 0
        text = opts[:text] || href
        title = href

        "<a href=\"#{href}\" title=\"#{title}\" rel=\"#{rel}\">#{text}</a>"
      end

      # Easy 404
      #
      def resource_not_found

        status 404

        @format = if m = @format.to_s.match( /^[^\/]+\/([^;]+)/ )
          m[1].to_sym
        else
          @format
        end
          # freaking sinata-respond_to 0.4.0... (or is that it ?)

        respond_to do |format|

          format.html {
            haml :resource_not_found
          }
          format.json {
            Rufus::Json.encode(
              { 'error' => {
                'code' => 404, 'message' => 'resource not found' } } )
          }
        end
      end

      # Easy 503
      #
      def workitems_not_available

        status 503

        respond_to do |format|

          format.html {
            haml :workitems_not_available
          }
          format.json { Rufus::Json.encode(
            { 'error' => {
              'code' => 503, 'messages' => 'Workitems not available' } } )
          }
        end
      end

      # Extract the process tree
      #
      def process_tree( object )

        case object
        when Ruote::Workitem
          process = engine.process( object.fei.wfid )
          Rufus::Json.encode( process.current_tree )
        when Ruote::ProcessStatus
          Rufus::Json.encode( object.current_tree )
        end
      end
    end
  end
end

