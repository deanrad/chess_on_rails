class Match < ActiveRecord::Base

  SIDES = [  ['White', '1'], ['Black', '2']  ]
  
  belongs_to :player1,	:class_name => 'Player'
  belongs_to :player2,	:class_name => 'Player'
  
  belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
  
  has_many :moves, :order => 'created_at ASC', :after_add => :after_add_move
  
  attr_reader :board
    
  def self.new_for( plyr1, plyr2, plyr2_side )
    plyr1, plyr2 = [plyr2, plyr1] if plyr2_side == '1'
    Match.new( :player1 => plyr1, :player2 => plyr2 )
  end
  
  def before_create
    self[:pieces] = Marshal.load( Marshal.dump( Chess.initial_pieces ) )
  end
  
  #TODO remove this after_find
  def after_find
    init_pieces unless pieces
  end
  
  def after_add_move(last_move)
    #update internal representation of the board
    play_move! last_move
    
    other_guy = (last_move.side == :black ? :white : :black)

    #TODO remove commented out checkmate_by in move after_add handler
    checkmate_by( last_move.side ) if board.in_checkmate?( other_guy )
  end
  
  def init_pieces
    #in test mode we dont store pieces in fixtures (yet) so we allow the repopulation as a convenience
    #raise StandardError, "Recalculating board - why were your pieces not initialized ?" unless RAILS_ENV == 'test'
    self[:pieces] = Marshal.load( Marshal.dump( Chess.initial_pieces ) )
    moves.each{ |m| play_move!(m) } #brings pieces up to date
  end  

  def board
    #every board has an independent copy of pieces
    #return Board.new( self, Marshal.load( Marshal.dump(pieces) ) )
    @board ||= Board.new( self, pieces )
  end
  
  #TODO remove this copy of play_move! from match
  def play_move!( m )
      #kill any existing piece we're moving onto or capturing enpassant
      pieces.reject!{ |p| (p.position == m.to_coord) || (p.position == m.captured_piece_coord) }	

      #move to that square
      piece_moved = nil
      pieces.each{ |p| p.position = m.to_coord and piece_moved = p if p.position==m.from_coord }

      #reflect castling
      if m.castled==1
          castling_rank = m.to_coord[1].chr
          [['g', 'f', 'h'], ['c', 'd', 'a']].each do |king_file, rook_file, orig_rook_file|
              #update the position of the rook if we landed on the kings castling square
              pieces.each { |p| p.position = "#{rook_file}#{castling_rank}" if m.to_coord[0].chr==king_file && p.position=="#{orig_rook_file}#{castling_rank}"}
          end
      end

      #reflect promotion
      piece_moved.promote!( Move::NOTATION_TO_ROLE_MAP[ m.promotion_choice ] ) if piece_moved && piece_moved.promotable? 
              
      self
  end
      
  def turn_of?( plyr )	
    self.next_to_move == side_of(plyr)
  end

  def next_to_move
    (moves.count & 1 == 0) ? :white : :black
  end

  def side_of( plyr ) 
    return :white if plyr == player1
    return :black if plyr == player2
  end

  def opposite_side_of( plyr )
    side_of(plyr) == :white ? :black : :white
  end

  def lineup
    "#{player1.name} vs. #{player2.name}"
  end

  def resign( plyr )
    self.result, self.active = ['Resigned', 0]
    self.winning_player = (plyr == player1) ? player2 : player1
    save!
  end

  def checkmate_by( side )
    self.result, self.active = ['Checkmate', 0]
    self.winning_player = (side == :white ? player1 : player2 )
    save!
  end

end
