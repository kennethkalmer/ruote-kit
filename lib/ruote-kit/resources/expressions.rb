
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/expressions/:id' do

    @process, @expression, fei = fetch_pef

    if fei

      return http_error(404) unless @expression

      etag @expression.to_h['_rev']

      respond_with :expression

    else

      return http_error(404) if @process.nil? or @process.expressions.empty?

      respond_with :expressions
    end
  end

  delete '/_ruote/expressions/:id' do

    process, expression, fei = fetch_pef

    return http_error(404) unless expression

    check_if_match_etag(expression.to_h['_rev'])

    if params[:_kill]
      RuoteKit.engine.kill_expression(expression.fei)
    else
      RuoteKit.engine.cancel_expression(expression.fei)
    end

    respond_to do |format|
      format.html { redirect url("/_ruote/expressions/#{expression.fei.wfid}") }
      format.json { json :status, :ok }
    end
  end

  put '/_ruote/expressions/:id' do

    process, exp, fei = fetch_pef

    return http_error(404) unless exp

    check_if_match_etag(exp.to_h['_rev'])

    info = begin
      fetch_expression_put_info
    rescue Rufus::Json::ParserError => pe
      return http_error(400, pe)
    end

    if state = info['state']

      if state == 'paused'
        RuoteKit.engine.pause(exp.fei, :breakpoint => info['breakpoint'])
      else
        RuoteKit.engine.resume(exp.fei)
      end

      path = Rack::Utils.unescape(request.path_info)
      path = path + '.json' if request.media_type.match(/json/) # :-(

      redirect(url(path))

    else

      RuoteKit.engine.re_apply(exp.fei, info)

      respond_to do |format|
        format.html { redirect url("/_ruote/expressions/#{exp.fei.wfid}") }
        format.json { json :status, :ok }
      end
    end
  end

  protected

  def fetch_pef

    fei = params[:id].split('!')
    wfid = fei.last

    process = RuoteKit.engine.process(wfid)

    expression = process ?
      process.expressions.detect { |exp| exp.fei.sid == params[:id] } :
      nil

    fei = (fei.length > 1)

    [ process, expression, fei ]
  end

  def fetch_expression_put_info

    if request.content_type == 'application/json'

      data = Rufus::Json.decode(request.body.read)

      data['expression'] ? data['expression'] : data

    else

      {
        'state' => params[:state],
        'breakpoint' => !!params[:breakpoint],
        :fields => params[:fields] ? Rufus::Json.decode(params[:fields]) : nil,
        :tree => params[:tree] ? Rufus::Json.decode(params[:tree]) : nil
      }
    end
  end
end

