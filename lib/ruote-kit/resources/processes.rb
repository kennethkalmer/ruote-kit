
# license is MIT, see LICENSE.txt


class RuoteKit::Application

  get '/_ruote/processes/?' do

    @processes = RuoteKit.engine.processes.sort_by { |pr|
      pr.launched_time
    }.reverse

    respond_to do |format|
      format.html { haml :processes }
      format.json { json(:processes, @processes) }
    end
  end

  get '/_ruote/processes/new' do

    haml :process_new
  end

  get '/_ruote/processes/:wfid' do

    @process = RuoteKit.engine.process(params[:wfid])

    if @process
      respond_to do |format|
        format.html { haml :process }
        format.json { json(:process, @process) }
      end
    else
      resource_not_found
    end
  end

  post '/_ruote/processes' do

    respond_to do |format|
      begin

        @info = fetch_launch_info

        @wfid = RuoteKit.engine.launch(
          @info.definition, @info.fields || {}, @info.variables || {})

      rescue Exception => @exception

        status 400

        format.html { haml :process_failed_to_launch }
        format.json { json(:exception, 400, @exception) }
      else

        status 201 # created

        format.html { haml :process_launched }
        format.json { json(:launched, @wfid) }
      end
    end
  end

  delete '/_ruote/processes/:wfid' do

    if params[:_kill] == '1'
      RuoteKit.engine.kill_process(params[:wfid])
    else
      RuoteKit.engine.cancel_process(params[:wfid])
    end

    respond_to do |format|
      format.html { redirect '/_ruote/processes' }
      format.json { json(:status, :ok) }
    end
  end

  protected

  def fetch_launch_info

    if request.content_type == 'application/json' then

      OpenStruct.new(Rufus::Json.decode(request.body.read))

    else

      info = OpenStruct.new('definition' => params[:definition])

      fields = params[:fields] || ''
      fields = '{}' if fields.empty?
      info.fields = Rufus::Json.decode(fields)

      vars = params[:variables] || ''
      vars = '{}' if vars.empty?
      info.variables = Rufus::Json.decode(vars)

      info
    end
  end
end

