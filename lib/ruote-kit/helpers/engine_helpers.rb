class RuoteKit::Application

  helpers do

    def engine
      RuoteKit.engine
    end

    def store_participant
      RuoteKit.engine.plist.lookup('.*')
    end

  end

end
