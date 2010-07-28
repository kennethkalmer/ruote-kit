
require 'sinatra/respond_to'
require 'haml'

Sinatra::Application.register Sinatra::RespondTo


module RuoteKit
  class Application < Sinatra::Application

    # delay these a bit

    configure do

      # we want to support Rails

      if defined?( Rails )
        set :environment, Rails.env
        disable :raise_errors unless Rails.env == 'development'
      end
    end

    set :views, File.join( File.dirname( __FILE__ ), 'views' )

    use(
      Rack::Static,
      :urls => %w[ /_ruote/images /_ruote/javascripts /_ruote/stylesheets ],
      :root => File.join( File.dirname( __FILE__ ), 'public' ))
    use(
      Rack::MethodOverride)

    helpers do
      include RuoteKit::Helpers::JsonHelpers
      include RuoteKit::Helpers::MiscHelpers
      include RuoteKit::Helpers::NavigationHelpers
      include RuoteKit::Helpers::RenderHelpers
    end

    before do

      # we allow the Accept header to be set to 'application/json'

      if env['HTTP_ACCEPT'] && env['HTTP_ACCEPT'] == 'application/json'
        format :json
      end
    end

    unless defined?( Rails )

      # handle 404s ourselves when not in Rails

      not_found do
        resource_not_found
      end
    end

    get '/_ruote/?' do

      respond_to do |format|

        format.html {
          haml :index
        }
        format.json {
          json :misc, "ruote-kit" => "welcome", "version" => RuoteKit::VERSION
        }
      end
    end

    Dir[ File.join( File.dirname( __FILE__ ), '/resources/*.rb') ].each { |r|
      load r
    }
  end
end

