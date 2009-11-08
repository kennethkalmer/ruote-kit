module RuoteKit
  module Spec
    module RuoteHelpers

      # Launch a dummy process and return the wfid
      def launch_test_process( &block )
        pdef = if block_given?
          yield
        else
          Ruote.process_definition :name => 'test' do
            sequence do
              nada
            end
          end
        end

        wfid = RuoteKit.engine.launch( pdef )

        Timeout.timeout 1 do
          sleep 0.1 while RuoteKit.engine.processes.empty?
        end

        wfid
      end

      def noisy( on = true )
        RuoteKit.engine.context[:noisy] = on
      end

    end
  end
end
