
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/expressions/?' do

    respond_to do |format|
      format.html { haml :expressions }
      format.json { json(:status, :ok) }
    end
  end

  get '/_ruote/expressions/:id' do

    @process, @expression, fei = fetch_pe

    return resource_not_found unless @process

    if fei

      return resource_not_found unless @expression

      respond_to do |format|
        format.html { haml :expression }
        format.json { json(:expression, @expression) }
      end
    else

      respond_to do |format|
        format.html { haml :expressions }
        format.json { json(:expressions, @process.expressions) }
      end
    end
  end

  delete '/_ruote/expressions/:id' do

    process, expression, fei = fetch_pe

    return resource_not_found unless expression

    if params[:_kill]
      RuoteKit.engine.kill_expression(expression.fei)
    else
      RuoteKit.engine.cancel_expression(expression.fei)
    end

    respond_to do |format|
      format.html { redirect "/_ruote/expressions/#{expression.fei.wfid}" }
      format.json { json(:status, :ok) } # TODO : really 200 ?
    end
  end

  protected

  def fetch_pe

    fei = params[:id].split('!')
    wfid = fei.last

    process = RuoteKit.engine.process(wfid)

    expression = process ?
      process.expressions.detect { |exp| exp.fei.sid == params[:id] } :
      nil

    fei = (fei.length > 1)

    [ process, expression, fei ]
  end
end

