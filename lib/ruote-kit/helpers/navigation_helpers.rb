
module RuoteKit
  module Helpers
    module NavigationHelpers

      def pluralize(number, word)

        word << 's' if number > 1

        return [ number, word ].join(' ')
      end

      def link_to(object, *args)

        case object
        when Ruote::ProcessStatus
          link_to_process(object)
        when Ruote::Workitem
          link_to_workitem(object)
        when String
          "<a href=\"#{args.first}\">#{object}</a>"
        end
      end

      def link_to_workitem(workitem)

        path = "/_ruote/workitems/#{workitem.fei.wfid}/#{workitem.fei.expid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

      def link_to_process(status)

        path = "/_ruote/processes/#{status.wfid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

      def link_to_expression(expression)

        path = "/_ruote/expressions/#{expression.fei.wfid}/#{expression.fei.expid}"

        "<a href=\"#{path}\">GET #{path}</a>"
      end

    end
  end
end
