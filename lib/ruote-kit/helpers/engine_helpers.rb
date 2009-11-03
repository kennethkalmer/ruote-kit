class RuoteKit::Application

  helpers do

    def engine
      RuoteKit.engine
    end

    def catchall
      RuoteKit.configuration.catchall_participant
    end

  end

end
