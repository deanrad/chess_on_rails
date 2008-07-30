# +Board+ like +Piece+, is a transient object, not stored in the database, but inferred, and
# used and disposed as needed for the purpose of implementing gameplay, and specifically tracking
# the location of +Piece+ s on the board and answering queries about the relationship of +Piece+ s
class Board < Hash
  
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
