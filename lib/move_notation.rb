# Extends Move with methods to be created from notation, and to save notation
# Separated out so that the core logic of notation is separated from the basics
# of moving when from and to coordinates are known.
module MoveNotation
  def self.included(move_klass)
    move_klass.class_eval do
      before_validation :infer_coordinates_from_notation
      before_save :notate_move
    end
  end

  # instance methods

  # Updates self[:notation] with the SAN notation for that move
  def notate_move
    self[:notation] = SAN.from_move(self)
  end

  # Updates self[:from_coord] and self[:to_coord] with the coordinates this
  # notation refers, to or if not possible, returns false to preempt further
  # validation or saving
  def infer_coordinates_from_notation
    return unless to_coord.blank? && from_coord.blank? && !notation.blank?

    san = SAN.new( self[:notation] )

    # the easy part
    self[:to_coord] = san.destination


    possible_movers = board.select do |pos, piece| 
      piece.function == san.role && 
      piece.allowed_moves(board).include?( san.destination.to_sym )
    end

    case possible_movers.length
      when 1
        self[:from_coord] = possible_movers[0][0].to_s
    end

    add_error(:notation, :invalid_notation) if (to_coord.blank? || from_coord.blank?)
  end
end
