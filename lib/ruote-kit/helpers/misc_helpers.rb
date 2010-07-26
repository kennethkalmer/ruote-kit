
module RuoteKit
  module Helpers

    module MiscHelpers

      def sample_process
        %{
Ruote.process_definition do
  sequence do
    alice :task => 'a'
    bob :task => 'b'
  end
end
        }.strip
      end
    end
  end
end

