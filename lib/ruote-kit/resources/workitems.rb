
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

  get '/_ruote/workitems/:id' do

    @workitem, @workitems, @wfid = fetch_wi

    return resource_not_found if @workitem.nil? && @workitems.nil?

    if @workitem

      respond_to do |format|
        format.html { haml :workitem }
        format.json { json( :workitem, @workitem ) }
      end

    else

      respond_to do |format|
        format.html { haml( :workitems ) }
        format.json { json( :workitems, @workitems ) }
      end
    end
  end

  put '/_ruote/workitems/:id' do

    workitem, _, _ = fetch_wi

    return resource_not_found unless workitem

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
          "/_ruote/workitems/#{workitem.fei.wfid}" :
          "/_ruote/workitems/#{workitem.fei.sid}" )
      }
      format.json {
        json( :workitem, workitem )
      }
    end
  end

  protected

  def fetch_wi

    fei = params[:id].split( '!' )
    wfid = fei.last

    workitem = nil
    workitems = nil

    wis = RuoteKit.engine.storage_participant.by_wfid( wfid )

    if fei.length > 1
      workitem = wis.find { |wi| wi.fei.sid == params[:id] }
    else
      workitems = wis
    end

    [ workitem, workitems, wfid ]
  end

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

        raise "#{env['CONTENT_TYPE']} is not supported for workitem fields"
    end

    options
  end
end

