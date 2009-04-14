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

  # allows it to be stored in a string field
  def to_s
    self.join " "
  end

end
