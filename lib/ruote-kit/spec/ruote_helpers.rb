
module RuoteKit
  module Spec

    module RuoteHelpers

      # Launch a dummy process and return the wfid
      #
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

        # give the engine some time to run the process
        # (remember it does it asynchronously)
        sleep( 0.350 )

        wfid
      end

      def noisy( on = true )
        RuoteKit.engine.noisy = on
      end

      def engine
        RuoteKit.engine
      end

      def storage_participant
        RuoteKit.engine.storage_participant
      end

      def find_workitem( wfid, expid )
        RuoteKit.engine.storage_participant.by_wfid( wfid ).first { |wi|
          wi.fei.expid == expid
        }
      end

      def wait_for( wfid )
        RuoteKit.engine.wait_for( wfid )
      end
    end
  end
end

