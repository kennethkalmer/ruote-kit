
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/errors/?' do

    @count = RuoteKit.engine.errors(:count => true)
    paginate

    @errors = RuoteKit.engine.errors(:skip => @skip, :limit => @limit)

    respond_with :errors
  end

  get '/_ruote/errors/:id' do

    @error, @errors = fetch_err

    return http_error(404) if @error.nil? && @errors.nil?

    if @error and request.accept.find { |as| as.match(/html/) }
      @process = RuoteKit.engine.process(@error.wfid)
      @pins = [ [ @error.fei.expid, 'error', 'er' ] ]
    end

    if @error
      respond_with :error
    else
      @count = @errors.size
      @skip = 0
      @limit = @count
      respond_with :errors
    end
  end

  # replay_at_error(e)
  #
  delete '/_ruote/errors/:fei' do

    fei = params[:fei]
    wfid = fei.split('!').last

    ps = RuoteKit.engine.process(wfid)
    error = ps.errors.find { |e| e.fei.sid == fei }

    RuoteKit.engine.replay_at_error(error)

    respond_to do |format|
      format.html { redirect url('/_ruote/errors') }
      format.json { json :status, :ok }
    end
  end

  protected

  def fetch_err

    fei = params[:id].split('!')
    wfid = fei.last

    error = nil
    process = RuoteKit.engine.process(wfid)
    errors = process ? process.errors : nil

    if errors && fei.length > 1
      error = errors.find { |er| er.fei.sid == params[:id] }
    end

    [ error, errors ]
  end
end

