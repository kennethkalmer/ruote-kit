module RuoteKit
  class Application < Sinatra::Application

    set :environment, DaemonKit.env

    use Rack::CommonLogger, RuoteKit.access_logger
    use Rack::Lint
    use Rack::MethodOverride

    get '/' do
      "Hello world!"
    end
  end
end
