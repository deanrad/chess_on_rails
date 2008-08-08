# A Move represents what a player did with respect to the pieces on the board in their turn.
# They may have:
# * moved a piece from +from_coord+ to +to_coord+
# * captured a piece at +capture_coord+ (usually but not always equal to +to_coord)
# * castled 
# * promoted a pawn to another piece 
#
# Also stored is the canonical notation for the move, in standard short algebraic form.
# See: http://en.wikipedia.org/wiki/Chess_notation for information on notation and coordinates
class Move < ActiveRecord::Base
  belongs_to :match, :counter_cache => true
  
  before_validation :infer_coordinates_from_notation
  
  validate  :ensure_coords_present_and_valid,
            :piece_must_be_present_on_from_coord,
            :piece_must_move_to_allowed_square,
            :piece_must_belong_to_that_player_who_is_next_to_move
  
  after_validation :update_capture_coord, :update_castling_field
  
  def infer_coordinates_from_notation
    @board ||= match.board if match
    #TODO fill out infer_coordinates_from_notation
  end

  def ensure_coords_present_and_valid
    [:from_coord, :to_coord].each do |coord|
      if self[coord].blank? 
        errors.add coord, "#{(coord == :from_coord ? 'From' : 'To') + ' coordinate' } must not be blank"
      else
        unless Position.new( self[coord] ).valid?
          errors.add coord, "#{self[coord]} did not specify a valid position"  
        end
      end
    end
  end
  
  def piece_must_be_present_on_from_coord
    @piece_moving ||= @board[ from_coord.to_sym ] if @board
    errors.add :from_coord, "No piece present at #{self[:from_coord]}" unless @piece_moving
  end
      
  def piece_must_move_to_allowed_square
    unless @piece_moving and @board.allowed_moves(from_coord).include?(to_coord)
      errors.add :to_coord, "#{self[:to_coord]} is not an allowed move for the piece at #{self[:from_coord]}" 
    end
  end
  
  def piece_must_belong_to_that_player_who_is_next_to_move
    if @piece_moving and @piece_moving.side != match.next_to_move
      errors.add_to_base "You can not move a #{@piece_moving.side} piece on #{match.next_to_move}'s turn"
    end
  end
  
  def update_capture_coord
    return unless @piece_moving and @piece_moving.kind_of?(Pawn)
    if @piece_moving.is_en_passant_capture( from_coord, to_coord - from_coord , @board)
      self[:capture_coord] = (Position.new(to_coord) + [ - Sides[@piece_moving.side].advance_direction, 0]).to_s
    end
  end
  
  def update_castling_field
    return unless @piece_moving and @piece_moving.kind_of?(King)
    self[:castled] = true if @piece_moving.is_castling_move?( from_coord, to_coord - from_coord, @board )
  end  
  
  #during the validation phase it is possible to know which side is moving because we look up the piece moving
  #Side_moving returns the side of that piece
  def side_moving
    return @piece_moving.side if @piece_moving
  end
  
  def from_coord
    self[:from_coord].to_sym
  end
  def from_coord=(val)
    self[:from_coord] = val.to_s
  end
  
  def to_coord
    self[:to_coord].to_sym
  end
  def to_coord=(val)
    self[:to_coord] = val.to_s
  end
  
  def capture_coord
    self[:capture_coord].to_sym if self[:capture_coord]
  end
  def capture_coord=(val)
    self[:capture_coord] = val.to_s
  end

end
