# A move queue is, at minimum, the response your expect your opponent to make,
# followed by your queued response to it. If your opponent makes the move you
# expected, your move will be played immediately
class MoveQueue < Array

  attr_accessor :valid

  def initialize( moves )
    return if moves.blank?

    moves.split( /[,; ]/ ).each do |m|
      self << m
    end
    self.valid = false unless self.length % 2 == 0
  end

  # returns whether the move queue detects a hit (correct prediction) based
  # on the actual move just made. Either an exact match on notation, or the
  # wildcard * will suffice to be a match.
  def hit?(actual_move)
    return false unless self.length > 1

    with(self[0]) do |expected|
      return true if expected == "*"
      return true if expected == actual_move.notation
      # from/to coord matching next
    end
    
    false
  end

  # allows it to be stored in a string field
  def to_s
    self.join " "
  end

end
