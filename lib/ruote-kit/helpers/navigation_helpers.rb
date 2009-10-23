class RuoteKit::Application

  helpers do

    def navigate_to( text, path )
      css_classes = []
      css_classes << 'first' if @first.nil?
      @first = true

      css_classes << 'active' if path.split('/')[1] == request.path.split('/')[1]

      "<li class=\"#{css_classes.join(' ')}\"><a href=\"#{ path }\">#{text}</a></li>"
    end
  end

end
