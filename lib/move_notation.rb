# Extends Move with methods to be created from notation, and to save notation
# Separated out so that the core logic of notation is separated from the basics
# of moving when from and to coordinates are known.
module MoveNotation
  def self.included(move_klass)
    move_klass.class_eval do
      before_save :notate_move
    end
  end

  # instance methods

  # Updates self[:notation] with the SAN notation for that move
  def notate_move
    self[:notation] = SAN.from_move(self)
  end

end
