
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/participants/?' do

    @participants = RuoteKit.engine.participant_list

    respond_with :participants
  end

  put '/_ruote/participants/?' do

    list = []

    if request.content_type.match(/\/json/)

      list = Rufus::Json.decode(request.body.read)
      list = list['participants'] if list.is_a?(Hash)

    else

      index = 0

      loop do

        break unless params["regex_#{index}"]

        list << {
          'regex' => params["regex_#{index}"],
          'classname' => params["classname_#{index}"],
          'options' => Rufus::Json.decode(params["options_#{index}"])
        }
        index = index + 1
      end
    end

    unless list.empty?
      RuoteKit.engine.participant_list = list
    end

    respond_to do |format|

      format.html do
        redirect url('/_ruote/participants')
      end
      format.json do
        @participants = RuoteKit.engine.participant_list
        json :participants
      end
    end
  end
end

