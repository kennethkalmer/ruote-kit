
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
  end

  after ( :each ) do

    if RuoteKit.engine
      RuoteKit.engine.shutdown
      RuoteKit.engine.storage.purge!
      RuoteKit.engine = nil
    end
  end
end

shared_examples_for 'it has an engine with no participants' do

  before( :each ) do

    RuoteKit.engine =
      Ruote::Engine.new(
        Ruote::Worker.new(
          Ruote::HashStorage.new ) )

    @tracer = Tracer.new
    RuoteKit.engine.add_service( 'tracer', @tracer )
  end

  after ( :each ) do

    if RuoteKit.engine
      RuoteKit.engine.shutdown
      RuoteKit.engine.storage.purge!
      RuoteKit.engine = nil
    end
  end
end

