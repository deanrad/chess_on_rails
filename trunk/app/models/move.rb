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
            :piece_must_belong_to_that_player_who_is_next_to_move,
            :must_not_leave_ones_king_in_check,
            :must_not_castle_across_check
  
  after_validation :update_capture_coord, :update_castling_field, :update_promotion_field

  after_save :check_for_mate
    
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
      errors.add_to_base "It is not #{@piece_moving.side}'s turn to move"
    end
  end
  
  def must_not_leave_ones_king_in_check
    #currently the presence of @piece_moving is used to short-circuit later validations
    return unless @piece_moving 
    currently_in_check = @board.in_check?( @piece_moving.side )
    @board.consider_move( self ) do
      #if their move will leave them in check at the end of it we need to void the move and tell them why
      if @board.in_check?( @piece_moving.side )
        if currently_in_check
          errors.add_to_base "You are in check and must move out of check"
        else
          errors.add_to_base "You can not move your king into check"
        end
      end
    end
  end
  
  #the square between a king and his destination castling square must not be under attack
  def must_not_castle_across_check
    return unless @piece_moving and @piece_moving.kind_of?(King)
    return unless @piece_moving.is_castling_move?( from_coord, to_coord - from_coord, @board )    
    
    interim_square = Position.new(from_coord) + (to_coord - from_coord == [0,2] ? [0,1] : [0,-1] )
    @board.consider_move( Move.new( :from_coord => from_coord, :to_coord => interim_square ) ) do
      if @board.in_check?(@piece_moving.side)
        errors.add_to_base "You can not castle across a square which is under attack"
      end
    end
  end

  #updates the field that helps us to replay enpassant
  def update_capture_coord
    return unless @piece_moving and @piece_moving.kind_of?(Pawn)
    if @piece_moving.is_en_passant_capture( from_coord, to_coord - from_coord , @board)
      self[:capture_coord] = (Position.new(to_coord) + [ - Sides[@piece_moving.side].advance_direction, 0]).to_s
    end
  end
  
  #updates the field that helps us to replay castling 
  def update_castling_field
    return unless @piece_moving and @piece_moving.kind_of?(King)
    self[:castled] = true if @piece_moving.is_castling_move?( from_coord, to_coord - from_coord, @board )
  end  
  
  #updates the field that helps us to replay promotion
  def update_promotion_field
    return unless @piece_moving and @piece_moving.kind_of?(Pawn)
    other_side = Sides.opposite_of(@piece_moving.side)
    if Position.new(to_coord).rank == Sides[other_side].back_rank
      self[:promotion_piece] ||= Piece.role_to_abbrev(:queen)
    end
  end
  
  #updates the match if the saving of this move resulted in checkmate
  def check_for_mate
    #update boards state
    return unless @board = match.board
    @board.move!(self) 
    #raise ArgumentError, "#{@board}"
    
    if @board.in_checkmate?( match.next_to_move  )
      match.update_attributes( :active => false, :winner => (match.next_to_move==:white ? match.player2 : match.player1)  )
    end
  end
  
  #during the validation phase it is possible to know which side is moving because we look up the piece moving
  #Side_moving returns the side of that piece
  def side_moving
    return @piece_moving.side if @piece_moving
  end
  
  #The from_coord indicates the beginning of a pieces' motion.
  #The fields *_coord are stored as strings, compared and manipulated as symbols
  def from_coord
    self[:from_coord].to_sym
  end
  def from_coord=(val)
    self[:from_coord] = val.to_s
  end
  
  #The to_coord indicates the endpoint of a pieces' motion.
  #The fields *_coord are stored as strings, compared and manipulated as symbols
  def to_coord
    self[:to_coord].to_sym
  end
  def to_coord=(val)
    self[:to_coord] = val.to_s
  end
  
  #The field capture_coord exists solely to help replay enpassant- the only move in Chess where a capture
  # occurs other than on the to_coord square
  #The fields *_coord are stored as strings, compared and manipulated as symbols
  def capture_coord
    self[:capture_coord].to_sym if self[:capture_coord]
  end
  def capture_coord=(val)
    self[:capture_coord] = val.to_s
  end

end
