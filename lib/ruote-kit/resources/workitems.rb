
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/workitems/?' do

    query = params.inject({}) { |h, (k, v)|
      h[k] = (Rufus::Json.decode(v) rescue v)
      h
    }

    @workitems = RuoteKit.engine.storage_participant.query(query)

    respond_to do |format|
      format.html { haml :workitems }
      format.json { json(:workitems, @workitems) }
    end
  end

  get '/_ruote/workitems/:id' do

    @workitem, @workitems, @wfid = fetch_wi

    return http_error(404) if @workitem.nil? && @workitems.nil?

    if @workitem

      respond_to do |format|
        format.html { haml :workitem }
        format.json { json(:workitem, @workitem) }
      end

    else

      respond_to do |format|
        format.html { haml(:workitems) }
        format.json { json(:workitems, @workitems) }
      end
    end
  end

  put '/_ruote/workitems/:id' do

    workitem, _, _ = fetch_wi

    return http_error(404) unless workitem

    options = begin
      field_updates_and_proceed_from_put
    rescue Rufus::Json::ParserError => pe
      return http_error(400, pe)
    end

    unless options[:fields].empty?
      workitem.fields = options[:fields]
      RuoteKit.engine.storage_participant.update(workitem)
    end

    if options[:proceed]
      RuoteKit.engine.storage_participant.reply(workitem)
    end

    respond_to do |format|

      format.html {
        redirect(options[:proceed] ?
          "/_ruote/workitems/#{workitem.fei.wfid}" :
          "/_ruote/workitems/#{workitem.fei.sid}")
      }
      format.json {
        json(:workitem, workitem)
      }
    end
  end

  protected

  def fetch_wi

    fei = params[:id].split('!')
    wfid = fei.last

    workitem = nil
    workitems = nil

    wis = RuoteKit.engine.storage_participant.by_wfid(wfid)

    if fei.length > 1
      workitem = wis.find { |wi| wi.fei.sid == params[:id] }
    else
      workitems = wis
    end

    [ workitem, workitems, wfid ]
  end

  def field_updates_and_proceed_from_put

    options = { :fields => {}, :proceed => false }

    if request.content_type == 'application/json'

      data = Rufus::Json.decode(env['rack.input'].read)
      if wi = data['workitem']; data = wi; end

      unless data['fields'].nil? || data['fields'].empty?
        options[:fields] = data['fields']
      end
      unless data['_proceed'].nil? || data['_proceed'].empty?
        options[:proceed] = data['_proceed']
      end

    else

      unless params['fields'].nil? || params['fields'].empty?
        options[:fields] = Rufus::Json.decode(params[:fields])
      end
      unless params[:_proceed].nil? || params[:_proceed].empty?
        options[:proceed] = params[:_proceed]
      end
    end

    options
  end
end

