class RuoteKit::Application

  get "/_ruote/expressions" do
    respond_to do |format|
      format.html { haml :expressions }
      format.json { json( :status, :ok ) }
    end
  end

  get "/_ruote/expressions/:wfid" do
    @process = engine.process( params[:wfid] )

    if @process
      respond_to do |format|
        format.html { haml :expressions }
        format.json { json( :expressions, @process.expressions ) }
      end
    else
      resource_not_found
    end
  end

  get "/_ruote/expressions/:wfid/:expid" do
    @process = engine.process( params[:wfid] )

    if @process && @expression = @process.expressions.detect { |exp| exp.fei.expid == params[:expid] }
      respond_to do |format|
        format.html { haml :expression }
        format.json { json( :expression, @expression ) }
      end
    else
      resource_not_found
    end
  end

  delete "/_ruote/expressions/:wfid/:expid" do
    process = engine.process( params[:wfid] )

    if process && expression = process.expressions.detect { |exp| exp.fei.expid == params[:expid] }
      if params[:_kill]
        engine.kill_expression( expression.fei )
      else
        engine.cancel_expression( expression.fei )
      end

      respond_to do |format|
        format.html { redirect "/_ruote/expressions/#{params[:wfid]}" }
        format.json { json( :status, :ok ) }
      end
    else
      resource_not_found
    end
  end

end
