
module RuoteKit
  module Helpers

    # Helpers for rendering stuff
    #
    module RenderHelpers

      def json( resource, *args )

        if respond_to?( "json_#{resource}" )
          object = send( "json_#{resource}", *args )
        end

        Rufus::Json.encode( {
          'links' => links( resource ),
          resource.to_s => object || args.first
        } )
      end

      def json_exception( code, exception )

        { 'code' => code, 'exception' => { 'message' => exception.message } }
      end

      def json_processes( processes )

        processes.map { |p| json_process( p ) }
      end

      def json_process( process )

        process.to_h.merge( 'links' => [
          link( "/_ruote/processes/#{process.wfid}", 'self' ),
          link( "/_ruote/expressions/#{process.wfid}", '#process_expressions' ),
          link( "/_ruote/workitems/#{process.wfid}", '#process_workitems' ),
          link( "/_ruote/errors/#{process.wfid}", '#process_errors' )
        ] )
      end

      def json_expression( expression )

        links = [
          link( "/_ruote/processes/#{expression.fei.wfid}", '#process' ),
          link( "/_ruote/expressions/#{expression.fei.wfid}", '#expressions' )
        ]

        links << link(
          "/_ruote/expressions/#{expression.fei.wfid}/#{expression.parent.fei.expid}",
          'parent' ) if expression.parent

        expression.to_h.merge( 'links' => links )
      end

      def json_expressions( expressions )

        expressions.map { |e| json_expression( e ) }
      end

      def json_workitems( workitems )

        workitems.map { |w| json_workitem( w ) }
      end

      def json_workitem( workitem )

        links = [
          link( "/_ruote/processes/#{workitem.fei.wfid}", '#process' ),
          link( "/_ruote/expressions/#{workitem.fei.wfid}", '#expressions' ),
          link( "/_ruote/errors/#{workitem.fei.wfid}", '#errors' )
        ]

        workitem.to_h.merge( 'links' => links )
      end

      def json_errors( errors )

        errors.collect { |e| json_error( e ) }
      end

      def json_error( error )

        fei = error.fei
        wfid = fei.wfid
        expid = fei.expid

        error.to_h.merge( 'links' => [
          link( "/_ruote/errors/#{wfid}/#{expid}", 'self' ),
          link( "/_ruote/errors/#{wfid}", '#process_errors' ),
          link( "/_ruote/processes/#{wfid}", '#process' )
        ] )
      end

      def links( resource )
        [
          link( '/_ruote', '#root' ),
          link( '/_ruote/processes', '#processes' ),
          link( '/_ruote/workitems', '#workitems' ),
          link( '/_ruote/errors', '#errors' ),
          link( '/_ruote/history', '#history' ),
          link( request.fullpath, 'self' )
        ]
      end

      def link( href, rel )
        {
          'href' => href,
          'rel' => rel.match( /^#/ ) ?
            "http://ruote.rubyforge.org/rels.html#{rel}" : rel
        }
      end

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

