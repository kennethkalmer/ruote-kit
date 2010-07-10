
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

        # give the engine some time to run the process
        # (remember it does it asynchronously)
        sleep( 0.350 )

        wfid
      end

      def noisy( on = true )
        RuoteKit.engine.context[:noisy] = on
      end

      def storage_participant
        RuoteKit.storage_participant
      end

      def find_workitem( wfid, expid )
        storage_participant.by_wfid( wfid ).detect { |wi| wi.fei.expid == expid }
      end

      def wait_for( wfid )
        @_spec_worker.context.logger.wait_for( [  wfid ] )
      end
    end
  end
end
