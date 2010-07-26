
class RuoteKit::Application

  get '/_ruote/processes/?' do

    @processes = engine.processes

    respond_to do |format|
      format.html { haml :processes }
      format.json { json( :processes, @processes ) }
    end
  end

  get '/_ruote/processes/new' do

    haml :launch_process
  end

  get '/_ruote/processes/:wfid' do

    @process = engine.process( params[:wfid] )

    if @process
      respond_to do |format|
        format.html { haml :process }
        format.json { json( :process, @process ) }
      end
    else
      resource_not_found
    end
  end

  post '/_ruote/processes' do

    launch_item = launch_item_from_post

    respond_to do |format|
      begin

        @wfid = engine.launch(
          launch_item['pdef'],
          launch_item['fields'],
          launch_item['variables'] )

      rescue ArgumentError => @error

        status 422

        format.html {
          haml :process_failed_to_launch
        }
        format.json {
          Rufus::Json.encode(
            { 'error' => { 'code' => 422, 'message' => @error.message } } )
        }
      else

        # status 200

        format.html { haml :process_launched }
        format.json { json( :launched, @wfid ) }
      end
    end
  end

  delete '/_ruote/processes/:wfid' do

    if params[:_kill] == '1'
      engine.kill_process( params[:wfid] )
    else
      engine.cancel_process( params[:wfid] )
    end

    respond_to do |format|
      format.html { redirect '/_ruote/processes' }
      format.json { json( :status, :ok ) }
    end
  end

  protected

  def launch_item_from_post

    case env['CONTENT_TYPE']

      when 'application/json' then

        data = Rufus::Json.decode( env['rack.input'].read )

        launch_item = {}
        launch_item['pdef'] = data['definition']
        launch_item['fields'] = data['fields'] || {}
        launch_item['variables'] = data['variables'] || {}

        launch_item

      when 'application/x-www-form-urlencoded'

        launch_item = { 'pdef' => params[:process_definition] }

        fields = params[:process_fields] || ''
        fields = '{}' if fields.empty?
        launch_item['fields'] = Rufus::Json.decode( fields )

        vars = params[:process_variables] || ''
        vars = '{}' if vars.empty?
        launch_item['variables'] = Rufus::Json.decode( vars )

        launch_item

      else

        raise "#{env['CONTENT_TYPE']} not supported as a launch mechanism"
    end
  end
end

