
# license is MIT, see LICENSE.txt


class RuoteKit::Application

  get '/_ruote/processes/?' do

    @count = RuoteKit.engine.processes(:count => true)
    paginate

    @processes = RuoteKit.engine.processes(
      :descending => true, :skip => @skip, :limit => @limit)

    respond_with :processes
  end

  get '/_ruote/processes/new' do

    haml :processes_new
  end

  get '/_ruote/processes/:wfid' do

    @process = RuoteKit.engine.process(params[:wfid])

    return http_error(404) if @process.nil? or @process.expressions.empty?

    @pins =
      @process.leaves.collect { |fexp|
        pin =
          if fexp.error
            [ 'error', 'er' ]
          elsif fexp.class == Ruote::Exp::ParticipantExpression
            [ 'workitem', 'wi' ]
          else
            [ 'other', '-' ]
          end
        [ fexp.fei.expid, *pin ]
      }

    respond_with :process
  end

  put '/_ruote/processes/:wfid' do

    @process = RuoteKit.engine.process(params[:wfid])

    return http_error(404) unless @process

    if fetch_put_info['state'] == 'paused'
      RuoteKit.engine.pause(params[:wfid])
    else
      RuoteKit.engine.resume(params[:wfid])
    end

    respond_with :process
  end

  post '/_ruote/processes' do

    begin

      @info = fetch_launch_info

      @wfid = RuoteKit.engine.launch(
        @info.definition, @info.fields || {}, @info.variables || {})

    rescue => e
      #p e
      #p e.ruby
      #puts e.ruby.backtrace
      #puts e.backtrace
      return http_error(400, e)
    end

    status 201 # created

    respond_to do |format|
      format.html { haml :process_launched }
      format.json { json :launched, @wfid }
    end
  end

  delete '/_ruote/processes/:wfid' do

    if params[:_kill] == '1'
      RuoteKit.engine.kill_process(params[:wfid])
    else
      RuoteKit.engine.cancel_process(params[:wfid])
    end

    respond_to do |format|
      format.html { redirect url('/_ruote/processes') }
      format.json { json :status, :ok }
    end
  end

  protected

  class LaunchInfo

    attr_accessor :definition, :fields, :variables

    def initialize(h={})

      @definition = h['definition'].strip
      @fields = h['fields']
      @variables = h['variables']

      if @definition.match(/^define /) && @definition.match(/\bend$/)
        @definition = 'Ruote.' + @definition
      end
    end
  end

  def fetch_put_info

    if request.content_type.match(/^application\/json(;.+)?$/)
      Rufus::Json.decode(request.body.read)
    else
      params
    end
  end

  def fetch_launch_info

    if request.content_type == 'application/json' then

      LaunchInfo.new(Rufus::Json.decode(request.body.read))

    else

      info = LaunchInfo.new('definition' => params[:definition])

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

