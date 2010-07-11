
class FuzzyParticipant
  include Ruote::LocalParticipant

  def consume( workitem )
    raise "broken"
  end
end

