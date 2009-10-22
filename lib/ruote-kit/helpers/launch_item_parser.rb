class RuoteKit::Application

  helpers do

    def launch_parameters
      case env["CONTENT_TYPE"]
      when "application/json" then
        return data = JSON.parse( env["rack.input"].read )
      else
        raise "Not supported yet (#{env['CONTENT_TYPE']})"
      end
    end

  end

end
