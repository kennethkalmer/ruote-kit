
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

      # Outputs a text like "11 to 15 of 15 processes"
      #
      def pagination_position

        to = [ @skip + @limit, @count ].min

        "#{@skip + 1} to #{to} of #{@count} #{request.path.split('/').last}"
      end
    end
  end
end

