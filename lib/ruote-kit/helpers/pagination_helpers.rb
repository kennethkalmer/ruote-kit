
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    # Pagination stuff
    #
    module PaginationHelpers

      # Prerequesite : a @count var with the number of records (processes,
      # workitems, errors or schedules) found.
      #
      def paginate(opts={})

        if s = params[:skip]; opts[:skip] = s.to_i; end
        if l = params[:limit]; opts[:limit] = l.to_i; end

        @skip = opts[:skip] || 0
        @limit = opts[:limit] || @count

        opts
      end
    end
  end
end

