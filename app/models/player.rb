class Player < ActiveRecord::Base
  
  has_many  :gameplays
  has_many  :matches, :through => :gameplays

  validates_length_of :name, :maximum => 20
  validates_uniqueness_of :name


  has_one    :user, :foreign_key => :playing_as

end
