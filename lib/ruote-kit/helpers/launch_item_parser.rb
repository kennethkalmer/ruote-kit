class RuoteKit::Application

  helpers do

    # Extract the launch item parameters from a posted form or a JSON request body
    def launch_item_from_post
      case env["CONTENT_TYPE"]

      when "application/json" then
        data = JSON.parse( env["rack.input"].read )
        launch_item = Ruote::Launchitem.new( data["uri"] || data["definition"] )
        launch_item.fields = data["fields"]
        return launch_item

      when "application/x-www-form-urlencoded"
        launch_item = Ruote::Launchitem.new( params[:process_definition] )
        launch_item.fields = JSON.parse( params[:process_fields] || "{}" )
        return launch_item

      else
        raise "#{env['CONTENT_TYPE']} not supported as a launch mechanism yet"
      end
    end

  end

end
