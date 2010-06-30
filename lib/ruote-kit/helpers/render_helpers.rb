module RuoteKit
  module Helpers
    # Helpers for rendering stuff
    module RenderHelpers

      def json( resource, object )
        if respond_to?( "json_#{resource}" )
          object = send( "json_#{resource}", object )
        end

        Rufus::Json.encode( {
          "links" => links( resource ),
          resource.to_s => object
        } )
      end

      def json_processes( processes )
        processes.map { |p| json_process( p ) }
      end

      def json_process( process )
        links = [
          link( "/_ruote/processes/#{process.wfid}", rel( '#process' ) ),
          link( "/_ruote/expressions/#{process.wfid}", rel( '#expressions' ) ),
          link( "/_ruote/workitems/#{process.wfid}", rel( '#workitems' ) )
        ]

        process.to_h.merge( 'links' => links )
      end

      def json_expression( expression )
        links = [
          link( "/_ruote/processes/#{expression.fei.wfid}", rel( '#process' ) ),
          link( "/_ruote/expressions/#{expression.fei.wfid}", rel( '#expressions' ) )
        ]

        if expression.parent
          links << link( "/_ruote/expressions/#{expression.fei.wfid}/#{expression.parent.fei.expid}", 'parent' )
        end

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
          link( "/_ruote/processes/#{workitem.fei.wfid}", rel( '#process' ) ),
          link( "/_ruote/expressions/#{workitem.fei.wfid}", rel( '#expressions' ) ),
          link( "/_ruote/errors/#{workitem.fei.wfid}", rel( '#errors' ) )
        ]

        workitem.to_h.merge( 'links' => links )
      end

      def json_errors( errors )
        errors.collect { |e| json_error( e, false ) }
      end

      def json_error( error )
        error.to_h.merge( 'links' => links )
      end

      def rel( fragment )
        "http://ruote.rubyforge.org/rels.html#{fragment}"
      end

      def links( resource )
        [
          link( '/_ruote', rel( '#root' ) ),
          link( '/_ruote/processes', rel( '#processes' ) ),
          link( '/_ruote/workitems', rel( '#workitems' ) ),
          link( '/_ruote/errors', rel( '#errors' ) ),
          link( '/_ruote/history', rel( '#history' ) ),
          link( request.fullpath, 'self' )
        ]
      end

      def link( href, rel )
        { 'href' => href, 'rel' => rel }
      end

      # Easy 404
      def resource_not_found
        status 404
        respond_to do |format|
          format.html { haml :resource_not_found }
          format.json { Rufus::Json.encode( { "error" => { "code" => 404, "message" => "Resource not found" } } ) }
        end
      end

      # Easy 503
      def workitems_not_available
        status 503
        respond_to do |format|
          format.html { haml :workitems_not_available }
          format.json { Rufus::Json.encode( { "error" => { "code" => 503, "messages" => "Workitems not available" } } ) }
        end
      end

      # Extract the process tree
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
