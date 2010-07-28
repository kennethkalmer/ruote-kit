
module RuoteKit
  module Helpers

    # Helpers for JSON rendering
    #
    module JsonHelpers

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

        processes.map { |p| json_process( p, false ) }
      end

      def json_process( process, detailed = true )

        process.to_h( detailed ).merge( 'links' => [
          link( "/_ruote/processes/#{process.wfid}", 'self' ),
          link( "/_ruote/processes/#{process.wfid}", '#process' ),
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

        error.to_h.merge( 'links' => [
          link( "/_ruote/errors/#{fei.sid}", 'self' ),
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
    end
  end
end

module Ruote

  # Re-opening process status to overwrite to_h
  #
  class ProcessStatus

    def to_h( detailed = false )

      h = {}

      #h['expressions'] = @expressions.collect { |e| e.fei.to_h }
      #h['errors'] = @errors.collect { |e| e.to_h }

      h['type'] = 'process'
      h['detailed'] = detailed
      h['expressions'] = @expressions.size
      h['errors'] = @errors.size
      h['stored_workitems'] = @stored_workitems.size
      h['workitems'] = workitems.size

      properties = %w[
        wfid
        definition_name definition_revision
        current_tree
        launched_time
        last_active
        tags
      ]

      properties += %w[
        original_tree
        variables
      ] if detailed

      properties.each { |m|
        h[m] = self.send( m )
      }

      h
    end
  end
end

