class RuoteKit::Application

  get "/_ruote/workitems" do

    @workitems = if params.empty?
      storage_participant.all
    else
      parsed_params = Hash.new

      params.each do |k,v|
        s = v.strip
        if(s[0] == '{' and s[-1] == '}')
          begin
            v = Rufus::Json.decode(s)['value']
          rescue JSON::ParserError
          rescue Yajl::ParseError
          end
        end
        parsed_params[k] = v
      end

      storage_participant.query(parsed_params)
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

    (resource_not_found and return) if workitem.nil?

    options = field_updates_and_proceed_from_put

    unless options[:fields].empty?
      workitem.fields = options[:fields]
      storage_participant.update( workitem )
    end

    if options[:proceed]
      storage_participant.reply( workitem )
    end

    respond_to do |format|
      format.html {
        redirect options[:proceed] ? "/_ruote/workitems/#{params[:wfid]}" : "/_ruote/workitems/#{params[:wfid]}/#{params[:expid]}"
      }
      format.json { json( :workitem, workitem ) }
    end
  end

end
