# +Board+ like +Piece+, is a transient object, not stored in the database, but inferred, and
# used and disposed as needed for the purpose of implementing gameplay, and specifically tracking
# the location of +Piece+ s on the board and answering queries about the relationship of +Piece+ s
#
# It keys on symbolized positions such as :a4

class Board < Hash

  FILES = [:a, :b, :c, :d, :e, :f, :g, :h]
  
  # changes the key (position symbol) under which this piece is stored
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

  def store(key, value)
    super if key.kind_of?(Symbol)
    super( key.to_sym, value )
  end
  
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
    #TODO a hash by position may improve performance- right now dynamic only
    moves = []
    allowed_moves_of_piece_at(position) { |move| moves << move.to_sym }
    moves
  end
  
  #The algorithm for in_check detection is a brute force search through all of your opponents
  # allowed moves to see whether one of them is the square your king is on. This could perhaps
  # be optimized to search backward from the king or some other such technique. Nonetheless, this
  # routine, and even checkmate even more so (since it calls this routine repeatedly) are ripe 
  # grounds to practice optimization
  def in_check?( side )
    #for all pieces which are owned by the opponent
    opponents_positions = keys.select{ |key| self[key].side != side }
    king_position = keys.detect{ |key| self[key].side==side and self[key].role==:king }
    
    #for all their allowed moves, we are in check if even one of them is our kings position
    opponents_positions.each do |pos|
      allowed_moves_of_piece_at(pos) do |move|
        return true if move.to_sym==king_position
      end
    end
    
    return false
  end
  
  #See the notes for in_check as well. The current algorithm for in_checkmate is: do you have a 
  # move you can play, at the end of which, you are no longer in check ? While I chose algorithmic
  # certainty over performance for the time being, I'm sure great gains in optimiztion can be had
  # by tuning this routine and the in_check it routine it depends on 
  def in_checkmate?( side )
    return false unless in_check?(side)
    defenders_positions = keys.select{ |key| self[key].side == side }
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
    
  
  #These variables help us track what's happened and allow us to undo
  attr_accessor :piece_last_moved, :piece_last_moved_from_coord
  attr_accessor :piece_captured, :piece_captured_from_coord
  attr_accessor :rook_castled, :rook_castled_from_coord, :rook_castled_to_coord
  attr_accessor :promoted_piece_last_side_id
  
  def move_and_record( move )
    #lift your piece off the square
    @piece_last_moved_from_coord = move.from_coord
    
    #if a capture is notated such as for enpassant, delete at that coordinate
    # otherwise delete whats moved upon. If nothing deleted, no worries
    @piece_last_moved = delete(move.from_coord) 
    
    #place any captured piece aside
    @piece_captured = move.capture_coord ? delete(move.capture_coord) : delete(move.to_coord)
    @piece_captured_from_coord = move.to_coord if @piece_captured
    
    #play castling
    if(move.castled)
      kings_square = Position.new(move.to_coord)
      #the rook is 3 to the right or 4 to the left (whites view) for king/queenside
      @rook_castled_from_coord = (kings_square + [0, (kings_square.file_char=='g') ? 1 : -2]).to_sym
      @rook_castled_to_coord   = (kings_square + [0, (kings_square.file_char=='g') ? -1 : 1]).to_sym
      @rook_castled = delete( rook_castled_from_coord )
      store( @rook_castled_to_coord, @rook_castled )
    end
        
    #and move your guy there
    store( move.to_coord, @piece_last_moved )
  end
  
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

