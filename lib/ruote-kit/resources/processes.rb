class RuoteKit::Application

  get "/processes" do
    @processes = RuoteKit.engine.processes

    respond_to do |format|
      format.html { haml :processes }
      format.json { json( :processes, @processes.collect { |p| p.to_h } ) }
    end
  end

  get "/processes/:wfid" do
    @process = RuoteKit.engine.process( params[:wfid] )

    respond_to do |format|
      format.html { haml :process }
      format.json { json( :process, @process.to_h ) }
    end
  end

  post "/processes" do
    launch_item = launch_parameters

    @wfid = RuoteKit.engine.launch( launch_item )

    respond_to do |format|
      format.html { redirect "/processes/#{@wfid}" }
      format.json { redirect "/processes/#{@wfid}.json" }
    end
  end

  delete "/processes/:wfid" do
    if params[:kill] == "1"
      RuoteKit.engine.kill_process( params[:wfid] )
    else
      RuoteKit.engine.cancel_process( params[:wfid] )
    end
  end
end
