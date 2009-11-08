class RuoteKit::Application

  get "/workitems" do
    @workitems = store_participant.all

    respond_to do |format|
      format.html { haml :workitems }
      format.json { json( :workitems, @workitems.map { |wi| wi.to_json } ) }
    end
  end

end
