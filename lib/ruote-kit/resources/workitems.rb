class RuoteKit::Application

  before do
    if request.path =~ /^\/_ruote\/workitems/ && !RuoteKit.catchall_configured?
      throw :halt, [ 503, workitems_not_available ]
    end
  end

  get "/_ruote/workitems" do
    if params[:participant]
      @participants = params[:participant].split(',')
      @workitems = @participants.inject([]) do |memo, part|
        memo.concat store_participant.by_participant( part )
      end
    else
      @workitems = store_participant.all
    end

    respond_to do |format|
      format.html { haml :workitems }
      format.json { json( :workitems, @workitems ) }
    end
  end

  get "/_ruote/workitems/:wfid" do
    @wfid = params[:wfid]
    @workitems = find_workitems( params[:wfid] )

    respond_to do |format|
      format.html { haml( :workitems ) }
      format.json { json( :workitems, @workitems ) }
    end
  end

  get "/_ruote/workitems/:wfid/:expid" do
    @workitem = find_workitem( params[:wfid], params[:expid] )

    if @workitem
      respond_to do |format|
        format.html { haml :workitem }
        format.json { json( :workitem, @workitem ) }
      end
    else
      resource_not_found
    end
  end

  put "/_ruote/workitems/:wfid/:expid" do
    workitem = find_workitem( params[:wfid], params[:expid] )

    options = field_updates_and_proceed_from_put

    unless options[:fields].empty?
      workitem.fields = options[:fields]
      store_participant.update( workitem )
    end

    if options[:proceed]
      store_participant.reply( workitem )
    end

    respond_to do |format|
      format.html {
        redirect options[:proceed] ? "/_ruote/workitems/#{params[:wfid]}" : "/_ruote/workitems/#{params[:wfid]}/#{params[:expid]}"
      }
      format.json { json( :workitem, workitem ) }
    end
  end

end
