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
  def self.initial_board
    b = Board.new 
    Sides.each do | side, back_rank, front_rank |
      b.store( :e + back_rank, Piece.new(:king,    side) )
      b.store( :d + back_rank, Piece.new(:queen,   side) )

      b.store( :a + back_rank, Piece.new(:rook,    side, :queens) )
      b.store( :b + back_rank, Piece.new(:knight,  side, :queens) )
      b.store( :c + back_rank, Piece.new(:bishop,  side, :queens) )

      b.store( :h + back_rank, Piece.new(:rook,    side, :kings) )
      b.store( :g + back_rank, Piece.new(:knight,  side, :kings) )
      b.store( :f + back_rank, Piece.new(:bishop,  side, :kings) )
      
      FILES.each do |file|
        b.store( file + front_rank, Piece.new(:pawn, side, file) )
      end
      
    end
    return b
  end
  
  def allowed_moves( position )
    #TODO a hash by position would be helpful - right now dynamic only
    moves = []
    allowed_moves_of_piece_at(position) { |move| moves << move }
    moves
  end
  
  #returns true if the enpassant exception applies to this piece moving as specified
  def en_passant?( piece_moving, from, to)
    return false unless piece_moving.role == :pawn
    return false #TODO flush this out - need more parameters, like the piece 'in-front-of' the EP square
  end
  
  private

  #on this board, interprets the piece's own allowed moves according to the state of the other pieces
  def allowed_moves_of_piece_at( position )
    return unless piece_moving = self[position]
    
    pos = Position.new(position)
    
    #for each line along which this piece can move
    piece_moving.lines_of_attack.each do |line|
      line_still_valid = true 
      
      
      #and for each step along that line
      line.each do |vector|
        new_position = pos + vector
    
        #if they're still on the board and still allowed to move this way
        if new_position.valid? and line_still_valid
          
          piece_at_new_position = self[new_position.to_sym]

          #they can move to empty squares - except pawns on diagonals without the enpassant exception
          if not piece_at_new_position
            unless piece_moving.role == :pawn
              yield new_position.to_sym  #allow the move
            else
              if new_position.file == pos.file
                if (new_position.rank - pos.rank == 1) or pos.rank==Sides[piece_moving.side].front_rank
                  yield new_position.to_sym
                end
              else
                yield new_position.to_sym if en_passant?( piece_moving, pos, new_position)
              end
            end
          else
            #they'll go no further
            line_still_valid = false
            
            #if its the opponents piece they may move here, but no further (not pawns)
            if piece_at_new_position.side != piece_moving.side
              yield new_position.to_sym if  piece_moving.role != :pawn || new_position.file != pos.file
            end
          end
        else
          line_still_valid = false
        end
      end
    end
    
    #and for each direct move to which this piece can move
    #TODO dry this copy of above logic up
    piece_moving.direct_moves.each do |vector| 
        new_position = pos + vector
        if new_position.valid?
          piece_at_new_position = self[new_position.to_sym]
          unless piece_at_new_position
            yield new_position.to_sym
          else
            if piece_at_new_position.side != piece_moving.side
              yield new_position.to_sym
            end
          end
          
        end
    end
  
  end
  
  
  #These variables help us track what's happened and allow us to undo
  attr_accessor :piece_last_moved, :piece_last_moved_from_coord
  attr_accessor :piece_captured, :piece_captured_from_coord
  attr_accessor :promoted_piece_last_side_id
  
  def move_and_record( move )
    #lift your piece off the square
    @piece_last_moved_from_coord = move.from_coord
    
    #if a capture is notated such as for enpassant, delete at that coordinate
    # otherwise delete whats moved upon. If nothing deleted, no worries
    @piece_last_moved = move.capture_coord ? delete(move.capture_coord) : delete(move.from_coord) 
    
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

