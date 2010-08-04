
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/expressions/:id' do

    @process, @expression, fei = fetch_pe

    return http_error(404) unless @process

    if fei

      return http_error(404) unless @expression

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

    return http_error(404) unless expression

    if params[:_kill]
      RuoteKit.engine.kill_expression(expression.fei)
    else
      RuoteKit.engine.cancel_expression(expression.fei)
    end

    respond_to do |format|
      format.html { redirect "/_ruote/expressions/#{expression.fei.wfid}" }
      format.json { json(:status, :ok) }
    end
  end

  put '/_ruote/expressions/:id' do

    process, expression, fei = fetch_pe

    return http_error(404) unless expression

    info = begin
      fetch_re_apply_info
    rescue Rufus::Json::ParserError => pe
      return http_error(400, pe)
    end

    #puts '-' * 80
    #p params
    #p info
    #puts '-' * 80

    options = {}
    options[:fields] = info.fields if info.fields
    options[:tree] = info.tree if info.tree

    RuoteKit.engine.re_apply(expression.fei, options)

    respond_to do |format|
      format.html { redirect "/_ruote/expressions/#{expression.fei.wfid}" }
      format.json { json(:status, :ok) }
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

  def fetch_re_apply_info

    if request.content_type == 'application/json' then

      OpenStruct.new(Rufus::Json.decode(request.body.read))

    else

      o = OpenStruct.new

      if fields = params[:fields]
        o.fields = Rufus::Json.decode(fields)
      end
      if tree = params[:tree]
        o.tree = Rufus::Json.decode(tree)
      end

      o
    end
  end
end

