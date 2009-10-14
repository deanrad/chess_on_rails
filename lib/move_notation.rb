# Extends Move with methods to be created from notation, and to save notation
# Separated out so that the core logic of notation is separated from the basics
# of moving when from and to coordinates are known.
module MoveNotation
  include KnowledgeOfBoard

  def self.included(move_klass)
    move_klass.class_eval do
      # gets called prior to Move#all_validations 
      validate :infer_coordinates_from_notation
      before_save :notate_move
      attr_accessor :possible_movers, :san
    end
  end

  # instance methods

  # Updates self[:notation] with the SAN notation for that move
  def notate_move
    self[:notation] = SAN.from_move(self) if self.notation.blank?
  end

  # Updates self[:from_coord] and self[:to_coord] with the coordinates this
  # notation refers, to or if not possible, returns false to preempt further
  # validation or saving
  def infer_coordinates_from_notation
    return unless to_coord.blank? && from_coord.blank? && !notation.blank?

    @san = SAN.new( self[:notation] )

    # first - castling, the retarded notation, and an early return
    if @san.castle
      self[:from_coord] = "#{KING_HOME_FILE}#{self.side.back_rank}" 
      self[:to_coord]   = "#{@san.castle_side.castling_file}#{self.side.back_rank}"
      return
    end

    # Now, parse the rest, to_coord being the easiest part
    self[:to_coord] = @san.destination

    @possible_movers = board.select do |pos, piece| 
      piece.function == san.role && 
      piece.allowed_moves(board).include?( san.destination.to_sym ) && 
      piece.side == self.side
    end

    case @possible_movers.length
      when 1
        self[:from_coord] = possible_movers.flatten.first.to_s
      when 0
        add_error(:notation, :notation_destination_invalid)
      else
        add_error(:notation, :notation_ambiguous)
    end

  end
end
