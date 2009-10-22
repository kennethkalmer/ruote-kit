module RuoteKit
  module Spec
    module RuoteHelpers

      # Launch a dummy process and return the wfid
      def launch_test_process( &block )
        pdef = if block_given?
          yield
        else
          Ruote.process_definition :name => 'test' do
            nana
          end
        end

        wfid = RuoteKit.engine.launch( pdef )

        sleep 0.1 while RuoteKit.engine.processes.empty?

        wfid
      end

    end
  end
end
