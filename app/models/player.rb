class Player < ActiveRecord::Base
  
  has_many  :gameplays
  has_many  :matches, :through => :gameplays

  validates_length_of :name, :maximum => 20
  validates_uniqueness_of :name


  has_one    :user, :foreign_key => :playing_as

  def new_match(other, they_play_white = false)
    with(Hash.new) do |players|
      players[:white] = they_play_white ? other : self
      players[:black] = they_play_white ? self  : other
      m = Match.new(players)
      m.save!
      m
    end
  end
end
