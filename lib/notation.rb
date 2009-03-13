module Notation; end # unconfuse rails' easily confused loader 

module PieceNotation

  # pieces other than pawn have notations for their role
  # memoizable
  def role_notation( role )
    return nil if role == 'pawn'
    role == 'knight' ? 'N' : role[0..0].upcase
  end

  #The part of the notation - with a piece disambiguator for pawns minors and rooks
  # It will be removed later if deemed unnecessary
  def notation( current_pawn_file = nil )
    role_notation(role) || current_pawn_file
  end

  # but uppercase for white, lower for black, and P for all pawns
  def abbrev
    single_char = role_notation(role) || 'p'
    return single_char.send( @side==:white ? 'upcase' : 'downcase' )
  end
end

module MoveNotation

  NOTATION_TO_ROLE_MAP = { 'R' => 'rook', 'N' => 'knight', 'B' => 'bishop', 'Q' => 'queen', 'K' => 'king' }

  # available to move model, sets fields on self based on self[:notation]
  def infer_coordinates_from_notation
    
    #expand the castling notation
    if self[:notation].include?('O-O')
      new_notation = 'K' + (self[:notation].include?('O-O-O') ? 'c' : 'g')
      new_notation += (match.next_to_move == :white) ? '1' : '8'
      self[:notation] = new_notation
    end
    
    self[:to_coord] =  notation.to_s[-2,2]
    role = NOTATION_TO_ROLE_MAP[ notation[0,1] ] ? NOTATION_TO_ROLE_MAP[ notation[0,1] ] : 'pawn'

    @possible_movers = @board.select do |pos, piece| 
      piece.side == match.next_to_move && 
      piece.role == role && 
      piece.allowed_moves(@board, pos).include?( self[:to_coord] )
    end

    self[:from_coord] = @possible_movers[0][0] if @possible_movers.length == 1
  end

  #returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
  def notate
    # allow calling outside of activerecord lifecycle
    analyze_board_position unless @board

    # start off with the pieces own notation
    mynotation = @piece_moving.notation( from_coord[0].chr )
    
    # disambiguate which piece moved if a 'sister_piece' could have moved there as well
    if( @piece_moving.role=='rook') || (@piece_moving.role=='knight')
      mynotation = mynotation[0].chr

      # look for a piece of the same type which also could have moved 
      sister_piece_pos, sister_piece = @board.consider_move(self) do |b|
          b.sister_piece_of(@piece_moving, from_coord)
      end

      if( sister_piece != nil && sister_piece.allowed_moves(@board, sister_piece_pos).include?(to_coord) )
        #prefer using file to disambiguate but use rank if file insufficient
        # mynotation += ( @piece_moving.file != sister_piece.file) ? @piece_moving.file : @piece_moving.rank
        mynotation += ( from_coord[0] != sister_piece_pos[0]) ? from_coord[0].chr : from_coord[1].chr
      end
    end
        
    if @piece_moved_upon && (@piece_moving.side != @piece_moved_upon.side) || @board.is_en_passant_capture?( from_coord, to_coord )
      mynotation += 'x' 
      captured = true
    end

    #notate the destination square - a straight append except for noncapturing pawns
    mynotation = '' if( (@piece_moving.role=='pawn') && !captured )
    mynotation += to_coord
        
    #castling 3 O's if queenside otherwise 2 O's
    if castled == 1
      mynotation = 'O-O' + ((to_coord[0].chr=='c') ? '-O' : '' ) 
    end

    #promotion
    if @piece_moving.promotable?( to_coord[1].chr )
      mynotation += "=#{promotion_choice}"
    end
    
    #check/mate
    mynotation += '+' if @board.consider_move(self) do |b|
      b.in_check?( @piece_moving.side==:white ? :black : :white )
    end

    return mynotation
  end

end
