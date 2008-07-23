class Match < ActiveRecord::Base

  #calling match.board(0).is_incheck? sets and returns self with as_of_move set to zero
  attr_accessor :as_of_move

  SIDES = [  ['White', '1'], ['Black', '2']  ]
  
  belongs_to :player1,	:class_name => 'Player', :foreign_key => 'player1'
  belongs_to :player2,	:class_name => 'Player', :foreign_key => 'player2'
  belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'
  
  has_many :moves, :order => 'created_at ASC', :after_add => :recalc_board_and_check_for_checkmate
    
  #AR callback - ensures a match object has a replayed board (those loaded from fixtures do not store piece data)
  #def after_find
  #  replay_board
  #end
  
  def self.new_for( plyr1, plyr2, plyr2_side )
    plyr1, plyr2 = [plyr2, plyr1] if plyr2_side == '1'
    Match.new( :player1 => plyr1, :player2 => plyr2 )
  end

  def before_create
    #start off with the default initial pieces setup
    self[:pieces] = Chess.initial_pieces.to_yaml
  end
  
  def board( as_of = nil )
    @as_of_move = as_of
    self
  end
      
  def recalc_board_and_check_for_checkmate(last_move)
    
    #by going through board accessor we can ensure its initialized
    
    #@board.play_move! last_move
    #board.play_move! last_move
    update_attributes! :pieces => @pieces.to_yaml
    
    other_guy = (last_move.side == :black ? :white : :black)

    #checkmate_by( last_move.side ) if @board.in_checkmate?( other_guy )
    checkmate_by( last_move.side ) if board.in_checkmate?( other_guy )
  end
    
  def replay_board
    @board = Board.new( self, Chess.initial_pieces )
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
