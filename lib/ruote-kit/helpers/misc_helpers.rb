
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

      def sample_process_tree

        Rufus::Json.encode(Ruote::Parser.parse(sample_process))
      end
    end
  end
end

