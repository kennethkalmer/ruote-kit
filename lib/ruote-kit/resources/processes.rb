class RuoteKit::Application

  get "/processes" do
    @processes = RuoteKit.engine.processes

    respond_to do |format|
      format.html { haml :processes }
      format.json { json( :processes, @processes ) }
    end
  end
end
