module RuoteKit
  module Helpers
    module EngineHelpers

      def engine
        RuoteKit.engine
      end

      def storage_participant
        RuoteKit.storage_participant
      end

      def find_workitems( wfid )
        storage_participant.by_wfid( wfid )
      end

      def find_workitem( wfid, expid )
        find_workitems( wfid ).detect { |wi| wi.fei.expid == expid }
      end

    end
  end
end

