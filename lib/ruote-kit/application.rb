require 'sinatra/respond_to'

module RuoteKit
  class Application < Sinatra::Application

    set :environment, DaemonKit.env

    use Rack::CommonLogger, RuoteKit.access_logger
    use Rack::Lint
    use Rack::MethodOverride

    before do
      # We allow the Accept header to be set to 'application/json'
      format :json if env["HTTP_ACCEPT"] && env["HTTP_ACCEPT"] == "application/json"
    end

    get '/' do
      respond_to do |format|
        format.html { "Hello world!" }
        format.json { { "ruote-kit" => "welcome", "version" => RuoteKit::VERSION }.to_json }
      end
    end

    Dir[ File.dirname(__FILE__) + '/helpers/*.rb' ].each { |h| load h }
    Dir[ File.dirname(__FILE__) + '/resources/*.rb' ].each { |r| load r }
  end
end

