class King < Piece
  def initialize(side)
    super(:king, side)
    
    DIAGONAL_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
    STRAIGHT_MOTIONS.each{ |move| @lines_of_attack << LineOfAttack.new(move, 1) }      
    
    #castling, king and queenside respectively works like a line of attack
    # in that no piece may lie between you and that square
    @lines_of_attack << LineOfAttack.new( [0, 2], 1) 
    @lines_of_attack << LineOfAttack.new( [0,-2], 1) 
      
  end
  
  def vector_allowed_from(here, vector, board=nil)
    return can_move_on_board(here, vector, board) if(board) 
  end
  
  #here the restrictions on castling are specified
  def can_move_on_board(here, vector, board)
    #we dont filter moves of length 1 here just the 2-long castling moves
    return true unless vector[1].abs == 2 
    return is_castling_move?(here, vector, board)
  end
  
  def is_castling_move?(here, vector, board)

    #figure out where we are
    position = Position.new(here)
    
    #king must be on initial square
    return false unless position.file_char=='e'
    
    #did i not instruct box 5 was to remain EMPTY ?! ensure intervening squares are empty
    intervening_square_1 = board[ position + ( vector==[0,-2] ? [0, -1] : [0,1] ) ]
    return false if intervening_square_1 != nil

    intervening_square_2 = board[ position + ( vector==[0,-2] ? [0, -2] : [0,2] ) ]
    return false if intervening_square_2 != nil

    #for queenside there must be no piece on the third square either
    return false if vector == [0,-2] and board[ position + [0, -3] ] != nil

    #now we look for the expected rook
    expected_rook = board[ position + ( vector==[0,-2] ? [0, -4] : [0,3] ) ]
    return false unless expected_rook and expected_rook.role == :rook and expected_rook.side == self.side
    
    #ok, those were all the rules, return true  (Oh, except for rules depending on move history)
    true
  end
end