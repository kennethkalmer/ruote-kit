
require 'ostruct'


class RuoteKit::Application

  get '/_ruote/processes/?' do

    @processes = engine.processes.sort_by { |pr| pr.wfid }.reverse

    respond_to do |format|
      format.html { haml :processes }
      format.json { json( :processes, @processes ) }
    end
  end

  get '/_ruote/processes/new' do

    haml :process_new
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

    respond_to do |format|
      begin

        @info = fetch_launch_info

        @wfid = engine.launch(
          @info.definition, @info.fields || {}, @info.variables || {})

      rescue Exception => @exception

        status 400

        format.html { haml :process_failed_to_launch }
        format.json { json( :exception, 400, @exception ) }
      else

        status 201 # created

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

  def fetch_launch_info

    case env['CONTENT_TYPE']

      when 'application/json' then

        OpenStruct.new( Rufus::Json.decode( env['rack.input'].read ) )

      when 'multipart/form-data'

        # TODO

        OpenStruct.new()

      when 'application/x-www-form-urlencoded'

        info = OpenStruct.new( 'definition' => params[:definition] )

        fields = params[:fields] || ''
        fields = '{}' if fields.empty?
        info.fields = Rufus::Json.decode( fields )

        vars = params[:variables] || ''
        vars = '{}' if vars.empty?
        info.variables = Rufus::Json.decode( vars )

        info

      else

        raise "#{env['CONTENT_TYPE']} not supported as a launch mechanism"
    end
  end
end

