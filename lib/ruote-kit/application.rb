require 'sinatra/respond_to'
require 'haml'

Sinatra::Application.register Sinatra::RespondTo

module RuoteKit
  class Application < Sinatra::Application

    # Delay these a bit
    configure do
      # We want to support Rails
      if defined?( Rails )
        set :environment, Rails.env
        disable :raise_errors unless Rails.env == 'development'
      end

      RuoteKit.ensure_engine!
    end

    set :views, File.join( File.dirname( __FILE__), 'views' )

    use Rack::Static, :urls => ['/_ruote/images', '/_ruote/javascripts', '/_ruote/stylesheets'], :root => File.join( File.dirname(__FILE__), 'public' )
    use Rack::MethodOverride

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

    unless defined?( Rails )
      # Handle 404's ourselves when not in Rails
      not_found do
        resource_not_found
      end
    end

    get '/_ruote' do
      respond_to do |format|
        format.html { haml :index }
        format.json { json :misc, "ruote-kit" => "welcome", "version" => RuoteKit::VERSION }
      end
    end

    Dir[ File.dirname(__FILE__) + '/resources/*.rb' ].each { |r| load r }
  end
end

