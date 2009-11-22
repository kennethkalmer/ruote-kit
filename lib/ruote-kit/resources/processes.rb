class RuoteKit::Application

  get "/processes" do
    @processes = engine.processes

    respond_to do |format|
      format.html { haml :processes }
      format.json { json( :processes, @processes ) }
    end
  end

  get "/processes/new" do
    haml :launch_process
  end

  get "/processes/:wfid" do
    @process = engine.process( params[:wfid] )

    if @process
      respond_to do |format|
        format.html { haml :process }
        format.json { json( :process, @process.to_h ) }
      end
    else
      resource_not_found
    end
  end

  post "/processes" do
    launch_item = launch_item_from_post

    @wfid = engine.launch( launch_item )

    respond_to do |format|
      format.html { redirect "/processes/#{@wfid}" }
      format.json { redirect "/processes/#{@wfid}.json" }
    end
  end

  delete "/processes/:wfid" do
    if params[:_kill] == "1"
      engine.kill_process( params[:wfid] )
    else
      engine.cancel_process( params[:wfid] )
    end

    respond_to do |format|
      format.html { redirect "/processes" }
      format.json { json( :status, :ok ) }
    end
  end
end
