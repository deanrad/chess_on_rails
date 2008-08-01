# A Match is a game of Chess between two players
class Match < ActiveRecord::Base
  
  belongs_to :player1,  :class_name => 'Player'
  belongs_to :player2,  :class_name => 'Player'
  belongs_to :winner,   :class_name => 'Player'
  
  #This match has a list of moves, played by each player in turn
  has_many :moves, :order => 'created_at ASC'

  # The player on the side of white- aka player1
  def white
    player1
  end

  # The player on the side of black- aka player2
  def black
    player2
  end
  
  # A formatted display of the players involved, white listed first
  def lineup
    "#{player1.name} vs. #{player2.name}"
  end

  def board() # as_of_move = nil
    #for now just return the initial board, played back to as many moves as we have
    Board.initial_board
  end
  
end
