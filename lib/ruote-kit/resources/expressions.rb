
# license is MIT, see LICENSE.txt

class RuoteKit::Application

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
      format.json { json(:status, :ok) }
    end
  end

  put '/_ruote/expressions/:id' do

    process, expression, fei = fetch_pe

    return resource_not_found unless expression

    info = fetch_re_apply_info

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

      #info = OpenStruct.new('definition' => params[:definition])
      #fields = params[:fields] || ''
      #fields = '{}' if fields.empty?
      #info.fields = Rufus::Json.decode(fields)
      #vars = params[:variables] || ''
      #vars = '{}' if vars.empty?
      #info.variables = Rufus::Json.decode(vars)
      #info
      {}
    end
  end
end

