#A Board is a snapshot of a match at a moment in time.
class Board

    attr_accessor :match	
    attr_accessor :pieces
    attr_accessor :as_of_move
    
    #todo remove need for pieces
    def initialize(match, pieces)
        #puts "initializing board"
        
        #initialize from the game's initial board, but replay moves...
        @pieces = pieces
        @match = match
        
        #this is the only supported option right now
        #@as_of_move = @match.moves.count
        
        #figure out the number of moves we're replaying to
        #if (as_of_move==:current)
        #    @as_of_move = @match.moves.count
        #elsif  as_of_move.to_i < 0
        #    @as_of_move = @match.moves.count + as_of_move.to_i
        #else
        #    @as_of_move = as_of_move.to_i
        #end
        
        #replay the board to that position
        #@match.moves[0..@as_of_move-1].each{ |m| play_move!(m) }
            
    end

    # updates internals with a given move played
    def play_move!( m )
        #kill any existing piece we're moving onto or capturing enpassant
        @pieces.reject!{ |p| (p.position == m.to_coord) || (p.position == m.captured_piece_coord) }	

        #move to that square
        piece_moved = nil
        @pieces.each{ |p| p.position = m.to_coord and piece_moved = p if p.position==m.from_coord }

        #reflect castling
        if m.castled==1
            castling_rank = m.to_coord[1].chr
            [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, rook_file, orig_rook_file|
                #update the position of the rook if we landed on the kings castling square
                @pieces.each { |p| p.position = "#{rook_file}#{castling_rank}" if m.to_coord[0].chr==king_file && p.position=="#{orig_rook_file}#{castling_rank}"}
            end
        end

        #reflect promotion
        piece_moved.promote!( Move::NOTATION_TO_ROLE_MAP[ m.promotion_choice ] ) if piece_moved && piece_moved.promotable? 
                
        self
    end

    #returns a copy of self with move played
    def consider_move(m)
        considered_board = Marshal::load(Marshal.dump(self)) #deep copy to decouple pieces array
        considered_board.play_move!(m)
    end

    #todo - can dry up these methods 

end