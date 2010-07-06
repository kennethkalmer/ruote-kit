
class RuoteKit::Application

  get '/_ruote/errors/?' do

    @errors = engine.errors

    respond_to do |format|
      format.html { haml :errors }
      format.json { json( :errors, @errors ) }
    end
  end

  get '/_ruote/errors/:wfid' do

    process = engine.process( wfid )
    @errors = process ? process.errors : nil

    if @errors
      respond_to do |format|
        format.html { haml :errors }
        format.json { json( :errors, @errors ) }
      end
    else
      resource_not_found
    end
  end

  get '/_ruote/errors/:wfid/:expid' do

    process = engine.process( wfid )
    errors = process ? process.errors : nil
    @error = errors ? errors.find { |e| e.fei.expid == expid } : nil

    if @error
      respond_to do |format|
        format.html { haml :error }
        format.json { json( :error, @error ) }
      end
    else
      resource_not_found
    end
  end

  # replay_at_error(e)
  #
  delete '/_ruote/errors/:wfid/:expid' do

    #process = engine.process( params[:wfid] )
    #if process && expression = process.expressions.detect { |exp| exp.fei.expid == params[:expid] }
    #  if params[:_kill]
    #    engine.kill_expression( expression.fei )
    #  else
    #    engine.cancel_expression( expression.fei )
    #  end
    #  respond_to do |format|
    #    format.html { redirect "/_ruote/expressions/#{params[:wfid]}" }
    #    format.json { json( :status, :ok ) }
    #  end
    #else
    #  resource_not_found
    #end
  end
end

