class RuoteKit::Application

  helpers do

    def button( text, css_class = nil )
      "<button type=\"submit\" class=\"#{css_class}\"><span><span>#{text}</span></span></button>"
    end

  end
end
