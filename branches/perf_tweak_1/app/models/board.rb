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
        @as_of_move = @match.moves.count
                
        #replay_moves
    end
    
    #replay the board into the current position
    def replay_moves
      @match.moves[0..@as_of_move-1].each{ |m| play_move!(m) }
      self
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
    def piece_at(pos)
        p = @pieces.find { |piece| piece.position == pos }
    end

    def [] ( pos ) 
        piece_at(pos)
    end

    def side_occupying(pos)
        p = piece_at(pos)
        return nil if !p 
        return p.side
    end

    def sister_piece_of( piece )
        p = @pieces.find { |p| (p.side == piece.side) && (p.role == piece.role ) && (p.position != piece.position) }
    end
    
    def in_check?( side )
        king_to_check = @pieces.find{ |p| p.role=='king' && p.side == side }

        @pieces.select { |p| p.side != side }.each do |attacker|
            #puts "Queen at #{attacker.position} with allowed moves #{attacker.allowed_moves(self) * ','} and king at #{king_to_check.position}" if attacker.role=='queen'
            return true if attacker.allowed_moves( self ).include?( king_to_check.position )
        end
        return false
    end

    def is_en_passant_capture?( from_coord, to_coord ) 

        to_rank, to_file = to_coord[1].chr, to_coord[0].chr
        return false unless p = piece_at( from_coord )

        capture_rank, advanced_pawn_rank, original_pawn_rank = (p.side==:white) ? %w{ 6 5 7 } : %w{ 3 4 2 }
        possible_advanced_pawn = piece_at( to_file + advanced_pawn_rank )

        #if behind a pawn
        if (to_rank == capture_rank) && possible_advanced_pawn && (possible_advanced_pawn.role=='pawn') 
            #and that pawn was doubly (not singly) advanced
            @match.moves.find_by_from_coord_and_to_coord( ( to_file + original_pawn_rank ) , possible_advanced_pawn.position ) != nil
        else
            return false
        end

    end

    #simplest logic here - if theres a move you're allowed which gets you out of check, you're not in checkmate
    #contrast with more intelligent Capture/Block/Evade strategy
    def in_checkmate?( side )

        return false unless in_check?( side )
            
        way_out = false
        @pieces.each do |p|
            next if p.side != side
            return false if way_out

            p.allowed_moves(self).each do |mv|
                hypothetical_board = self.consider_move( Move.new( :from_coord => p.position, :to_coord => mv ) )
                way_out = true unless hypothetical_board.in_check?( side )
            end
        end
        return !way_out
    end
end