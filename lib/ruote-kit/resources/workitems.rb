class RuoteKit::Application

  get "/workitems" do
    @workitems = store_participant.all

    respond_to do |format|
      format.html { haml :workitems }
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

  end

end
