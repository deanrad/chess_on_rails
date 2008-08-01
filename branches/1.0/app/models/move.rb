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
  belongs_to :match
  
  before_validation :infer_coordinates_from_notation
  validate :ensure_coords_present_and_valid, :piece_must_be_present_on_from_coord, :piece_must_move_to_allowed_square
  
  def infer_coordinates_from_notation
    @board ||= match.board
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
    #TODO fill out piece_must_be_present_on_from_coord
    @piece_moving ||= @board[ from_coord.to_sym ]
    errors.add :from_coord, "No piece present at #{self[:from_coord]}" unless @piece_moving
  end
      
  def piece_must_move_to_allowed_square
    unless @board.allowed_moves(from_coord).include?(to_coord)
      errors.add :to_coord, "#{self[:to_coord]} is not an allowed move for the piece at #{self[:from_coord]}" 
    end
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
