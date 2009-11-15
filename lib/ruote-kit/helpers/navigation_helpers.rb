class RuoteKit::Application

  helpers do

    def navigate_to( text, path )
      css_classes = []
      css_classes << 'first' if @first.nil?
      @first = true

      css_classes << 'active' if path.split('/')[1] == request.path.split('/')[1]

      "<li class=\"#{css_classes.join(' ')}\"><a href=\"#{ path }\">#{text}</a></li>"
    end

    def pluralize( number, word )
      if number > 1
        word << 's'
      end

      return [ number, word ].join(' ')
    end

    def link_to( object )
      case object
      when Ruote::Workitem
        link_to_workitem( object )
      end
    end

    def link_to_workitem( workitem )
      path = "/workitems/#{workitem.fei.wfid}/#{workitem.fei.expid}"

      "<a href=\"#{path}\">GET #{path}</a>"
    end
  end

end
