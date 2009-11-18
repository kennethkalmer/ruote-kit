class RuoteKit::Application

  get "/workitems" do
    @workitems = store_participant.all

    respond_to do |format|
      format.html { haml :workitems }
      format.json { json( :workitems, @workitems.map { |wi| wi.to_h } ) }
    end
  end

  get "/workitems/:wfid" do
    @wfid = params[:wfid]
    @workitems = find_workitems( params[:wfid] )

    respond_to do |format|
      format.html { haml( :workitems ) }
      format.json { json( :workitems, @workitems.map { |wi| wi.to_h } ) }
    end
  end

  get "/workitems/:wfid/:expid" do
    @workitem = find_workitem( params[:wfid], params[:expid] )

    if @workitem
      respond_to do |format|
        format.html { haml :workitem }
        format.json { json( :workitem, @workitem.to_h ) }
      end
    else
      resource_not_found
    end
  end

  put "/workitems/:wfid/:expid" do
    workitem = find_workitem( params[:wfid], params[:expid] )

    options = field_updates_and_proceed_from_put

    unless options[:fields].empty?
      workitem.fields = options[:fields]
      store_participant.consume( workitem )
    end

    if options[:proceed]
      store_participant.reply( workitem )
    end

    # TODO: This needs to be different dependending on whether we proceed or update
    respond_to do |format|
      format.html { redirect "/workitems/#{params[:wfid]}/#{params[:expid]}" }
      format.json { json( :workitem, workitem.to_h ) }
    end
  end

end
