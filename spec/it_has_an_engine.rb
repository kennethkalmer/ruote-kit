
shared_examples_for 'it has an engine' do

  before( :each ) do

    RuoteKit.engine =
      Ruote::Engine.new(
        Ruote::Worker.new(
          Ruote::HashStorage.new ) )

    @tracer = Tracer.new
    RuoteKit.engine.add_service( 'tracer', @tracer )

    RuoteKit.engine.register do
      catchall Ruote::StorageParticipant
    end

    ## Specs use their own worker since we need the trace
    #@_spec_worker = Ruote::Worker.new( RuoteKit.engine.storage )
    #@_spec_worker.context.add_service( 'tracer', @tracer )
    #@_spec_worker.run_in_thread
  end

  after ( :each ) do

    if RuoteKit.engine
      RuoteKit.engine.shutdown
      RuoteKit.engine.storage.purge!
      RuoteKit.engine = nil
    end

    #@_spec_worker.shutdown
  end
end

