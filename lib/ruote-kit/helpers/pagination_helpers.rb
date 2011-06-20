
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    #
    # Pagination stuff
    #
    module PaginationHelpers

      # Prerequesite : a @count var with the number of records (processes,
      # workitems, errors or schedules) found.
      #
      def paginate

        @skip = (params[:skip] || 0).to_i
        @limit = (params[:limit] || settings.limit).to_i

        if @skip <= 0
          @skip = 0
        elsif @skip >= @count
          @skip = @count - @limit
        end
      end
    end
  end
end

