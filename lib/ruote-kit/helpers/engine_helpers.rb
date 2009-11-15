class RuoteKit::Application

  helpers do

    def engine
      RuoteKit.engine
    end

    def store_participant
      RuoteKit.engine.plist.lookup('.*')
    end

    def find_workitem( wfid, expid )
      workitems = store_participant.by_wfid( wfid )

      workitems.detect { |wi| wi.fei.expid == expid }
    end

  end

end
