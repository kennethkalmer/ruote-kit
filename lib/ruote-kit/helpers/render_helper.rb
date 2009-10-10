# Helpers for rendering stuff

class RuoteKit::Application

  helpers do

    def json( resource, object )
      {
        "links" => links( resource ),
        resource => object
      }.to_json
    end

    def rel( fragment )
      "http://ruote.rubyforge.org/rels.html#{ fragment }"
    end

    def links( resource )
      links = [
        link( '/', rel('#root') ),
        link( '/processes', rel('#processes') ),
        link( request.fullpath, 'self' )
      ]
    end

    def link( href, rel )
      { 'href' => href, 'rel' => rel }
    end

  end
end
