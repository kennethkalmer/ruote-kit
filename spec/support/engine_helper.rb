
class Tracer
  def initialize
    @trace = ''
  end
  def to_s
    @trace.to_s.strip
  end
  def << s
    @trace << s
  end
  def clear
    @trace = ''
  end
  def puts s
    @trace << "#{s}\n"
  end
end


module EngineHelper

  def prepare_engine

    RuoteKit.engine =
      Ruote::Engine.new(
        Ruote::Worker.new(
          Ruote::HashStorage.new))

    @tracer = Tracer.new
    RuoteKit.engine.add_service('tracer', @tracer)
  end

  def register_participants

    RuoteKit.engine.register do
      catchall Ruote::StorageParticipant
    end
  end

  def prepare_engine_with_participants

    prepare_engine
    register_participants
  end

  def shutdown_and_purge_engine

    return unless RuoteKit.engine

    RuoteKit.engine.shutdown
    RuoteKit.engine.storage.purge!
    RuoteKit.engine = nil
  end

  def launch_nada_process

    pdef = Ruote.process_definition :name => 'test' do
      nada
    end

    wfid = RuoteKit.engine.launch(pdef)

    RuoteKit.engine.wait_for(:nada)
    RuoteKit.engine.wait_for(1)

    wfid
  end

  def noisy(on = true)

    RuoteKit.engine.noisy = on
  end

  def engine

    RuoteKit.engine
  end

  def storage_participant

    RuoteKit.engine.storage_participant
  end

  def find_workitem(wfid, expid)

    RuoteKit.engine.storage_participant.by_wfid(wfid).first { |wi|
      wi.fei.expid == expid
    }
  end

  def wait_for(wfid)

    RuoteKit.engine.wait_for(wfid)
  end
end

