module RuoteKit
  module Helpers
    module NavigationHelpers

      def navigate_to( text, path )
        css_classes = []
        css_classes << 'first' if @first.nil?
        @first = true

        css_classes << 'active' if path.split('/')[2] == request.path.split('/')[2]

        "<li class=\"#{css_classes.join(' ')}\"><a href=\"#{ path }\">#{text}</a></li>"
      end

      def pluralize( number, word )
        if number > 1
          word << 's'
        end

        return [ number, word ].join(' ')
      end

      def link_to( object, *args )
        case object
        when Ruote::ProcessStatus
          link_to_process( object )
        when Ruote::Workitem
          link_to_workitem( object )
        when String
          "<a href=\"#{args.first}\">#{object}</a>"
        end
      end

      def link_to_workitem( workitem )
        path = "/_ruote/workitems/#{workitem.fei.wfid}/#{workitem.fei.expid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

      def link_to_process( status )
        path = "/_ruote/processes/#{status.wfid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

      def link_to_expression( expression )
        path = "/_ruote/expressions/#{expression.fei.wfid}/#{expression.fei.expid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

    end
  end
end
