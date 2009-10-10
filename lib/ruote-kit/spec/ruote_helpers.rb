module RuoteKit
  module Spec
    module RuoteHelpers

      # Launch a dummy process and return the wfid
      def launch_test_process
        pdef = Ruote.process_definition :name => 'test' do
          nana
        end

        wfid = RuoteKit.engine.launch( pdef )

        sleep 0.1 while RuoteKit.engine.processes.empty?

        wfid
      end

      # Purge the engine of all running processes
      def purge_engine
        RuoteKit.engine.context.values.each do |s|
          s.purge if s.respond_to?( :purge )
        end
      end
    end
  end
end
