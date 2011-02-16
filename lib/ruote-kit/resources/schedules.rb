
# license is MIT, see LICENSE.txt

class RuoteKit::Application

  get '/_ruote/schedules/?' do

    @count = RuoteKit.engine.schedules(:count => true)
    paginate

    @schedules = RuoteKit.engine.schedules(:skip => @skip, :limit => @limit)

    respond_with :schedules
  end

  get '/_ruote/schedules/:wfid' do

    @schedules = RuoteKit.engine.schedules(params[:wfid])

    @count = @schedules.size
    @skip = 0
    @limit = @count

    respond_with :schedules
  end
end

