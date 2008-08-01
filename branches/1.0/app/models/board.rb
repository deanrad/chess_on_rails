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

  def squares_occupied
    return keys
  end
  
  def pieces
    return values
  end
  
  def store(key, value)
    super if key.kind_of?(Symbol)
    super( key.to_sym, value )
  end
  
  #return chess pieces as they appear at the start of a match
  #TODO replace verbose Position.as_symbol(:e, back_rank) with :e + back_rank
  def self.initial_board
    b = Board.new 
    Sides.each do | side, back_rank, front_rank |
      b.store( :e + back_rank, Piece.new(:king,    side) )
      b.store( :d + back_rank, Piece.new(:queen,   side) )

      b.store( :a + back_rank, Piece.new(:rook,    side, :queen) )
      b.store( :b + back_rank, Piece.new(:knight,  side, :queen) )
      b.store( :c + back_rank, Piece.new(:bishop,  side, :queen) )

      b.store( :h + back_rank, Piece.new(:rook,    side, :king) )
      b.store( :g + back_rank, Piece.new(:knight,  side, :king) )
      b.store( :f + back_rank, Piece.new(:bishop,  side, :king) )
      
      FILES.each do |file|
        b.store( file + front_rank, Piece.new(:pawn, side, :file) )
      end
      
    end
    return b
  end
  
  private
  
  #These variables help us track what's happened and allow us to undo
  attr_accessor :piece_last_moved, :piece_last_moved_from_coord
  attr_accessor :piece_captured, :piece_captured_from_coord
  attr_accessor :promoted_piece_last_side_id
  
  def move_and_record( move )
    #lift your piece off the square
    @piece_last_moved_from_coord = move.from_coord
    @piece_last_moved = delete(move.from_coord)
    
    #place any captured piece aside
    @piece_captured = delete(move.to_coord)
    @piece_captured_from_coord = move.to_coord if @piece_captured
    
    #and move your guy there
    store( move.to_coord, @piece_last_moved )
  end
  
  def undo_move( move )
    #lift your piece off the destination square
    delete(move.to_coord)
    
    #restore any captured piece
    store( @piece_captured_from_coord, @piece_captured) if @piece_captured
    
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
end

