require 'sinatra/respond_to'

module RuoteKit
  class Application < Sinatra::Base

    set :environment, DaemonKit.env
    set :views, DaemonKit.root + '/lib/ruote-kit/views'
    set :public, DaemonKit.root + '/lib/ruote-kit/public'
    set :static, true

    use Rack::CommonLogger, RuoteKit.access_logger
    use Rack::Lint
    use Rack::MethodOverride
    use Rack::ShowExceptions

    helpers do
      include RuoteKit::Helpers::EngineHelpers
      include RuoteKit::Helpers::FormHelpers
      include RuoteKit::Helpers::LaunchItemParser
      include RuoteKit::Helpers::NavigationHelpers
      include RuoteKit::Helpers::RenderHelpers
    end

    before do
      # We allow the Accept header to be set to 'application/json'
      format :json if env["HTTP_ACCEPT"] && env["HTTP_ACCEPT"] == "application/json"
    end

    not_found do
      resource_not_found
    end

    get '/' do
      respond_to do |format|
        format.html { haml :index }
        format.json { json :misc, "ruote-kit" => "welcome", "version" => RuoteKit::VERSION }
      end
    end

    Dir[ File.dirname(__FILE__) + '/resources/*.rb' ].each { |r| load r }
  end
end

