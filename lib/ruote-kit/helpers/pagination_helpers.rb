
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    # Pagination stuff
    #
    module PaginationHelpers

      # Prerequesite : a @count var with the number of records (processes,
      # workitems, errors or schedules) found.
      #
      def paginate

        @skip = (params[:skip] || 0).to_i
        @limit = (params[:limit] || @count).to_i
      end
    end
  end
end

