# +Board+ like +Piece+, is a transient object, not stored in the database, but inferred, and
# used and disposed as needed for the purpose of implementing gameplay, and specifically tracking
# the location of +Piece+ s on the board and answering queries about the relationship of +Piece+ s
#
# It keys on symbolized positions such as :a4

class Board < Hash

  FILES = [:a, :b, :c, :d, :e, :f, :g, :h]
  
  # plays a move without the intent to undo that move
  def move!( move )
    move_and_record(move)
  end
  
  # Allows you to pass in a block to query what this board would be like had a move been played
  # after which the effect of having considered the move is undone
  def consider_move( move )
    move_and_record(move)
    yield
    undo_move(move)    
  end

  #stores a piece, ensuring it is keyed by the symbol of the position
  def store(key, value)
    super if key.kind_of?(Symbol)
    super( key.to_sym, value )
  end
  
  #retrieves a piece, ensuring the intended key is checked as a symbol
  def [](key)
    super if key.kind_of?(Symbol)
    super( key.to_sym  )
  end
  
  #return chess pieces as they appear at the start of a match
  def self.initial_board
    b = Board.new 
    Sides.each do | side, back_rank, front_rank |
      b.store( :e + back_rank, King.new(side) )
      b.store( :d + back_rank, Queen.new(side) )

      b.store( :a + back_rank, Rook.new(side, :queens ) )
      b.store( :b + back_rank, Knight.new(side, :queens ) )
        b.store( :c + back_rank, Bishop.new(side, :queens ) )

      b.store( :h + back_rank, Rook.new(side, :kings ) )
      b.store( :g + back_rank, Knight.new(side, :kings ) )
      b.store( :f + back_rank, Bishop.new(side, :kings ) )
      
      FILES.each do |file|
        b.store( file + front_rank, Pawn.new(side, file) )
      end
      
    end
    return b
  end
  
  #The board looks at all of a pieces unblocked moves, and then may take away certain moves
  # depending on whether they leave you in check, etc..
  def allowed_moves( position )
    moves = []
    allowed_moves_of_piece_at(position) { |move| moves << move.to_sym }
    moves
  end
  
  #The algorithm for in_check detection now searches backward from the king for pieces who could 
  # be attacking it - this makes it unnecessary to search all the opponents possible moves
  def in_check?( side )
    king_position = keys.detect{ |key| self[key].side==side and self[key].role==:king }

    return true if pawn_is_attacking_king?(side, king_position)

    return true if knight_is_attacking_king?(side, king_position)
    
    return true if diagonal_piece_is_attacking_king?(side, king_position)
    
    return true if straight_piece_is_attacking_king?(side, king_position)
    
    false
  end
  
  #See the notes for in_check as well. The current algorithm for in_checkmate is: do you have a 
  # move you can play, at the end of which, you are no longer in check ? I'm sure great gains in
  # optimiztion can be had by tuning this routine and the in_check it routine it depends on 
  def in_checkmate?( side )
    return false unless in_check?(side)
    defenders_positions = keys.select{ |key| self[key] && self[key].side == side }
    defenders_positions.each do |defender_position|
      allowed_moves_of_piece_at(defender_position) do |defense_move|
        consider_move( Move.new(:from_coord => defender_position, :to_coord => defense_move ) ) do
          return false unless in_check?(side)
        end
      end
    end
    return true
  end
  
  private

  #on this board, interprets the piece's own allowed moves according to the state of the other pieces
  #allowed_moves_of_piece_at is the iterator version called by allowed_moves(position)
  def allowed_moves_of_piece_at( position )
    return unless piece_moving = self[position]
    
    #for each line along which this piece can move (we dont use desired moves for perf reasons)
    unblocked_moves = piece_moving.unblocked_moves(position, self)
    unblocked_moves.each do |move_vector|
      new_position = Position.new(position) + move_vector
      yield new_position if new_position.valid?
    end
  end
    
  def pawn_is_attacking_king?(side, king_position)
    upfield = side==:white ? 1 : -1 #the direction an attacking pawn would come from
    [ [upfield, 1], [upfield, -1] ].each do |possible_pawn_direction|
        square = Position.new(king_position) + possible_pawn_direction
        next unless square.valid?
        return true if self[square] and self[square].side != side and self[square].role==:pawn
    end
    false
  end
  
  def diagonal_piece_is_attacking_king?(side, king_position)
    return piece_type_is_attacking_king?(side, king_position, Piece::DIAGONAL_MOTIONS, [:queen, :bishop] )
  end
  def straight_piece_is_attacking_king?(side, king_position)
    return piece_type_is_attacking_king?(side, king_position, Piece::STRAIGHT_MOTIONS, [:queen, :rook] )
  end

  def piece_type_is_attacking_king?( side, king_position, motion_types, role_types)
    lines= []
    motion_types.each { |motion| lines << LineOfAttack.new(motion) }
    lines.each do |line|
      line.each do |vector|
        square = Position.new(king_position) + vector
        break unless square.valid?
        
        #move on down the line if no piece found
        next unless self[square]
        
        #otherwise see if validly attacked
        return true if self[square].side != side and role_types.include?( self[square].role )
          
        #or blocker - ignore the rest of this line
        break
      end
    end
    false
  end
    
  def knight_is_attacking_king?(side, king_position)
    Piece::KNIGHT_MOVES.each do |vector|
      square = Position.new(king_position) + vector
      next unless square.valid?
      
      #move on down the line if no piece found
      next unless self[square]
      
      #otherwise see if validly attacked
      return true if self[square].side != side and self[square].role == :knight
    end
    false
  end
  
  #These variables help us track what's happened and allow us to undo
  attr_accessor :piece_last_moved, :piece_last_moved_from_coord
  attr_accessor :piece_captured, :piece_captured_from_coord
  attr_accessor :rook_castled, :rook_castled_from_coord, :rook_castled_to_coord
  attr_accessor :promoted_pawn
  
  #plays a move against the board and saves enough information in instance variables 
  # to allow undoing the move if necessary
  def move_and_record( move )
    #lift your piece off the square
    @piece_last_moved_from_coord = move.from_coord
    @piece_last_moved = delete(move.from_coord) 
    
    #store any captured piece and the coordinates we got them from
    if move.capture_coord
      @piece_captured = delete(move.capture_coord)
      @piece_captured_from_coord = move.capture_coord
    else
      @piece_captured = delete(move.to_coord)
      @piece_captured_from_coord = move.to_coord if @piece_captured
    end
    
    #play castling
    if(move.castled)
      kings_square = Position.new(move.to_coord)
      #the rook is 3 to the right or 4 to the left (whites view) for king/queenside
      @rook_castled_from_coord = (kings_square + [0, (kings_square.file_char=='g') ? 1 : -2]).to_sym
      @rook_castled_to_coord   = (kings_square + [0, (kings_square.file_char=='g') ? -1 : 1]).to_sym
      @rook_castled = delete( rook_castled_from_coord )
      store( @rook_castled_to_coord, @rook_castled )
    end
    
    #if promotion we remove the pawn and place a new one 
    if( move.promotion_piece ) 
      @promoted_pawn = @piece_last_moved
      promoted_piece = Queen.new(@promoted_pawn.side)
      promoted_piece.instance_variable_set(:@which, :promoted)
      store( move.to_coord, promoted_piece )
    else
      #otherwise we just move your guy there
      store( move.to_coord, @piece_last_moved )
    end
    
  end
  
  #uses data cached in the board to undo the most recent move
  def undo_move( move )
    #lift your piece off the destination square
    delete(move.to_coord)
    
    #restore any captured piece
    store( @piece_captured_from_coord, @piece_captured) if @piece_captured
    
    #revert the rook move part of castling
    if @rook_castled_to_coord 
      rook = delete(@rook_castled_to_coord)
      store( @rook_castled_from_coord, rook )
    end
    
    #revert promotion happens auto..
    #if @promoted_pawn
    #  @piece_last_moved.instance_variable_set(:@role,   @promoted_piece_last_role  )
    #  @piece_last_moved.instance_variable_set(:@which,  @promoted_piece_last_which )
    #end
    
    #replace your piece back on the original square
    store( @piece_last_moved_from_coord, @piece_last_moved )
  end
  
end

#Extension to symbol for more expressive position manipulation
class Symbol
  #allows :a + rank etc..
  def +(other)
    (self.to_s + other.to_s).to_sym
  end
  
  #allows :b4 - :a4 to be expressed as [1,0], the move you must add to a4 to get to b4
  def -(other)
    destination = Position.new(self)
    origin = Position.new(other)
    return (destination-origin) if destination.valid? and origin.valid?
  end
end

