
class Rack::MockResponse

  def json_body
    Rufus::Json.decode(body)
  end

  def json?
    begin
      json_body
      return true
    rescue
      return false
    end
  end

  def html?
    ! json?
  end
end

