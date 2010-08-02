
# license is MIT, see LICENSE.txt

module RuoteKit
  module Helpers

    module MiscHelpers

      def sample_process
        %{
Ruote.process_definition :name => 'test', :revision => '0.1' do
  sequence do
    alice :task => 'clean car'
    bob :task => 'sell car'
  end
end
        }.strip
      end
    end
  end
end

