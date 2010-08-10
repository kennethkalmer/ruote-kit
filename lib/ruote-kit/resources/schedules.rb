
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/schedules/?' do

    @schedules = RuoteKit.engine.schedules

    respond_to do |format|
      format.html { haml :schedules }
      format.json { json :schedules }
    end
  end

  get '/_ruote/schedules/:wfid' do

    @schedules = RuoteKit.engine.schedules(params[:wfid])

    respond_to do |format|
      format.html { haml :schedules }
      format.json { json :schedules }
    end
  end
end

