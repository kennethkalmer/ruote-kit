class RuoteKit::Application

  get "/expressions" do
    respond_to do |format|
      format.html { haml :expressions }
      format.json { json( :status, :ok ) }
    end
  end
end
