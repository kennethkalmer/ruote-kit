
class RuoteKit::Application

  get '/_ruote/workitems/?' do

    query = params.inject({}) { |h, (k, v)|
      h[k] = (Rufus::Json.decode(v) rescue v)
      h
    }

    @workitems = storage_participant.query(query)

    respond_to do |format|
      format.html { haml :workitems }
      format.json { json( :workitems, @workitems ) }
    end
  end

  get '/_ruote/workitems/:wfid' do

    @wfid = params[:wfid]
    @workitems = find_workitems( params[:wfid] )

    respond_to do |format|
      format.html { haml( :workitems ) }
      format.json { json( :workitems, @workitems ) }
    end
  end

  get '/_ruote/workitems/:wfid/:expid' do

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

  put '/_ruote/workitems/:wfid/:expid' do

    workitem = find_workitem( params[:wfid], params[:expid] )

    ( resource_not_found and return ) if workitem.nil?

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
        redirect( options[:proceed] ?
          "/_ruote/workitems/#{params[:wfid]}" :
          "/_ruote/workitems/#{params[:wfid]}/#{params[:expid]}" )
      }
      format.json {
        json( :workitem, workitem )
      }
    end
  end

  protected

  def field_updates_and_proceed_from_put

    options = { :fields => {}, :proceed => false }

    case env['CONTENT_TYPE']

      when 'application/json' then

        data = Rufus::Json.decode( env['rack.input'].read )

        unless data['fields'].nil? || data['fields'].empty?
          options[:fields] = data['fields']
        end
        unless data['_proceed'].nil? || data['_proceed'].empty?
          options[:proceed] = data['_proceed']
        end

      when 'application/x-www-form-urlencoded'

        unless params['fields'].nil? || params['fields'].empty?
          options[:fields] = Rufus::Json.decode( params[:fields])
        end
        unless params[:_proceed].nil? || params[:_proceed].empty?
          options[:proceed] = params[:_proceed]
        end

      else

        raise "#{evn['CONTENT_TYPE']} is not supported for workitem fields"
    end

    options
  end
end

