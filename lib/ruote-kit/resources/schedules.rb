
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/schedules/?' do

    @schedules = RuoteKit.engine.schedules

    respond_with :schedules
  end

  get '/_ruote/schedules/:wfid' do

    @schedules = RuoteKit.engine.schedules(params[:wfid])

    respond_with :schedules
  end
end

