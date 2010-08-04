
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/schedules/?' do

    @schedules = RuoteKit.engine.context.storage.get_many('schedules')
    @schedules = @schedules.collect { |sched| Ruote.schedule_to_h(sched) }

    respond_to do |format|
      format.html { haml :schedules }
      format.json { json(:schedules, @schedules) }
    end
  end
end

