
class RuoteKit::Application

  get '/_ruote/errors/?' do

    @errors = RuoteKit.engine.errors

    respond_to do |format|
      format.html { haml :errors }
      format.json { json(:errors, @errors) }
    end
  end

  get '/_ruote/errors/:id' do

    @error, @errors = fetch_e

    return resource_not_found if @error.nil? && @errors.nil?

    if @error

      respond_to do |format|
        format.html { haml :error }
        format.json { json(:error, @error) }
      end

    else

      respond_to do |format|
        format.html { haml :errors }
        format.json { json(:errors, @errors) }
      end
    end
  end

  # replay_at_error(e)
  #
  delete '/_ruote/errors/:wfid/:expid' do

    #process = engine.process(params[:wfid])
    #if process && expression = process.expressions.detect { |exp| exp.fei.expid == params[:expid] }
    #  if params[:_kill]
    #    engine.kill_expression(expression.fei)
    #  else
    #    engine.cancel_expression(expression.fei)
    #  end
    #  respond_to do |format|
    #    format.html { redirect "/_ruote/expressions/#{params[:wfid]}" }
    #    format.json { json(:status, :ok) }
    #  end
    #else
    #  resource_not_found
    #end
  end

  protected

  def fetch_e

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

