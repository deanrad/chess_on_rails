module Notation; end # unconfuse rails' easily confused loader 

# Provides notation services when included in Move class. 
# Kept separately somewhat in vain - they are highly interdependent
# source code files..
module MoveNotation

  NOTATION_TO_FUNCTION_MAP = { 'K' => :king, 'Q' => :queen,
                               'R' => :rook, 'N' => :knight, 'B' => :bishop  }

  # available to move model, sets fields on self based on self[:notation]
  # temporarily expands the castling notation to Kg2 
  # - if g2 is in K's allowed move list from it's from_coord then we're good
  def infer_coordinates_from_notation

    if self[:notation].include?('O-O')
      file = self[:notation].include?('O-O-O') ? 'c' : 'g'
      rank = match.next_to_move == :white ? '1' : '8'
      self[:notation] = "K#{file}#{rank}"
    end

    self[:to_coord] =  notation.to_s[-2,2]
    function = NOTATION_TO_FUNCTION_MAP[ notation[0,1] ] || :pawn
    @possible_movers = board.select do |pos, piece| 
      piece.side == match.next_to_move && 
      piece.function == function && 
      piece.allowed_moves(board).include?( self[:to_coord].to_sym )
    end

    self[:from_coord] = @possible_movers[0][0] and return if @possible_movers.length == 1
    disambiguator = notation[-3,1]
    matcher = (disambiguator =~ /[1-8]/) ? Regexp.new( "^.#{disambiguator}$" ) : Regexp.new( "^#{disambiguator}.$" )
    movers = @possible_movers.select { |pos, piece| matcher.match(pos) }

    self[:from_coord] = movers[0][0] and return if movers.length == 1

  end

  # Returns the notation for a given move - depends on alot of things - whether check was given, a capture made, etc..
  # - Prefer using file to disambiguate but use rank if file insufficient
  # - Most pieces have their piecetype abbreviation ( N for knight ), pawns have their file
  def notate
    # allow calling outside of activerecord lifecycle
    analyze_board_position unless @board

    mynotation = @piece_moving.abbrev.upcase.sub('P', from_coord.file)
    
    # disambiguate which piece moved if a 'sister_piece' could have moved there as well
    if( @piece_moving.function==:rook) || (@piece_moving.function==:knight)
      mynotation = mynotation.file

      sister_piece_pos, sister_piece = @board.sister_piece_of(@piece_moving)

      if( sister_piece != nil && sister_piece.allowed_moves(@board).include?(to_coord.to_sym) )
        mynotation += ( from_coord.file != sister_piece_pos.file) ? from_coord.file : from_coord.rank.to_s
      end
    end
        
    if @piece_moved_upon && (@piece_moving.side != @piece_moved_upon.side) || @board.en_passant_capture?( from_coord, to_coord )
      mynotation += 'x' 
      captured = true
    end

    #notate the destination square - a straight append except for noncapturing pawns
    mynotation = '' if( (@piece_moving.function==:pawn) && !captured )
    mynotation += to_coord
        
    #castling 3 O's if queenside otherwise 2 O's
    debugger
    if castled == 1
      mynotation = 'O-O' + ((to_coord.file=='c') ? '-O' : '' ) 
    end

    #promotion
    if @piece_moving.function == :pawn && to_coord.to_s.rank == @piece_moving.promotion_rank
      self.promotion_choice ||= 'Q'
      mynotation += "=#{promotion_choice}"
    end
    
    #check/mate
    in_check = false
    @board.consider_move(self) do |b|
      in_check = b.in_check?( @piece_moving.side==:white ? :black : :white )
    end

    mynotation += '+' if in_check
    # debugger
    #raise "Move id #{id} #{from_coord}->#{to_coord} in Notation#notate"

    return mynotation
  end

end
