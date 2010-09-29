
# license is MIT, see LICENSE.txt

require 'sinatra/respond_to'
require 'haml'

module RuoteKit
  class Application < Sinatra::Application

    register Sinatra::RespondTo

    # delay these a bit

    configure do

      # we want to support Rails

      if defined?(Rails)
        set :environment, Rails.env
        disable :raise_errors unless Rails.env == 'development'
      end
    end

    set :limit, 100

    set :views, File.join(File.dirname(__FILE__), 'views')

    use(
      Rack::Static,
      :urls => %w[ /_ruote/images /_ruote/javascripts /_ruote/stylesheets ],
      :root => File.join(File.dirname(__FILE__), 'public'))
    use(
      Rack::MethodOverride)

    Dir[File.join(File.dirname(__FILE__), 'helpers/*.rb')].each { |r| load r }

    helpers do
      include RuoteKit::Helpers::LinkHelpers
      include RuoteKit::Helpers::JsonHelpers
      include RuoteKit::Helpers::MiscHelpers
      include RuoteKit::Helpers::RenderHelpers
      include RuoteKit::Helpers::PaginationHelpers
    end

    before do

      # we allow the Accept header to be set to 'application/json'

      if env['HTTP_ACCEPT'] && env['HTTP_ACCEPT'] == 'application/json'
        format :json
      end
    end

    unless defined?(Rails)

      # handle 404s ourselves when not in Rails

      not_found do
        http_error(404)
      end
    end

    get '/_ruote/?' do

      respond_to do |format|

        format.html do
          haml :index
        end
        format.json do
          json :misc, 'ruote-kit' => 'welcome', 'version' => RuoteKit::VERSION
        end
      end
    end

    Dir[File.join(File.dirname(__FILE__), 'resources/*.rb')].each { |r| load r }
  end
end

