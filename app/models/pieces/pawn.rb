class Pawn < Piece

  ALLOWED_PROMOTIONS = [:queen, :rook, :bishop, :knight]  

  def initialize(side, which)
    super(:pawn, side, which)

    #figure out which way is forward
    forward = Sides[@side].advance_direction
    
    #a short line-of-attack in the forward direction
    @lines_of_attack << LineOfAttack.new( [forward, 0] , 2 ) 
    
    #and the diagonal forward moves
    [1,-1].each{ |diag| @lines_of_attack << LineOfAttack.new( [forward, diag], 1 ) }
    
  end

  
  def vector_allowed_from(here, vector, board=nil)
    return can_move_on_board(here, vector, board) if(board) 
    
    if vector == [2,0] or vector == [-2,0] 
      return true if Position.new(here).rank == Sides[@side].front_rank  
    else
      return true
    end
  end
  
  def can_move_on_board(here, vector, board)
    #straight shot 
    new_position = Position.new(here) + vector
    piece_at_new_position = board[new_position]
    if vector == [2,0] or vector == [-2,0] 
      
      #must be on its own side front rank (thus its initial rank)
      return false unless Position.new(here).rank == Sides[@side].front_rank
    end
    
    moving_diagonally = vector[1]!=0
    if moving_diagonally and piece_at_new_position
      return (piece_at_new_position.side != self.side)
    elsif moving_diagonally and not piece_at_new_position
      return is_en_passant_capture(here, vector, board)
    else
      return (piece_at_new_position == nil)
    end
  end
  
  def is_en_passant_capture(here, vector, board)
    this_position = Position.new(here)
    new_position = Position.new(here) + vector
    pawn_attempting_capture = board[this_position]

    #we expect to find an opponents' pawn 'behind' (whatever that means to the capturing pawn) the 
    # intended destination square
    return false unless pawn_attempting_capture
    
    expected_pawn_position = new_position + [ - Sides[pawn_attempting_capture.side].advance_direction, 0]
    
    return false unless board[expected_pawn_position] && 
                        board[expected_pawn_position].role==:pawn &&
                        board[expected_pawn_position].side != self.side
    
    true
  end
end