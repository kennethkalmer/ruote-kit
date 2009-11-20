module RuoteKit
  module Helpers
    module FormHelpers

      def button( text, css_class = nil )
        "<button type=\"submit\" class=\"#{css_class}\"><span><span>#{text}</span></span></button>"
      end

    end
  end
end
