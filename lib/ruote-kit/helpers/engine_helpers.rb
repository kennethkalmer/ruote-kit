class RuoteKit::Application

  helpers do

    def engine
      RuoteKit.engine
    end

    def store_participant
      RuoteKit.engine.plist.lookup('.*')
    end

    def find_workitems( wfid )
      store_participant.by_wfid( wfid )
    end

    def find_workitem( wfid, expid )
      find_workitems( wfid ).detect { |wi| wi.fei.expid == expid }
    end

  end

end
