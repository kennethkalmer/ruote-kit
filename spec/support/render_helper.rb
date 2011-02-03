
module RenderHelper

  def app

    RuoteKit::Application
  end

  def render(template, scope=nil, locals={}, &block)

    template = File.read(File.join(app.views, template.to_s))
    engine = Haml::Engine.new(template)
    engine.render(scope, locals, &block)
  end
end

