class Player < ActiveRecord::Base
  
  validates_length_of :name, :maximum => 20
  validates_uniqueness_of :name

  has_one    :user, :foreign_key => :playing_as
  # --OR--
  has_one    :fbuser, :foreign_key => :playing_as

  def facebook_id
    return nil unless fbuser
    fbuser.facebook_user_id
  end

  has_many  :matches, :class_name => "Match",
    :finder_sql => 'SELECT matches.* FROM matches WHERE ( player1_id = #{id} OR player2_id= #{id} )'

  has_many :active_matches, :class_name => "Match",
    :finder_sql => 'SELECT matches.* FROM matches WHERE ( player1_id = #{id} OR player2_id= #{id} ) AND active=1'

  has_many :completed_matches, :class_name => "Match",
    :finder_sql => 'SELECT matches.* FROM matches WHERE ( player1_id = #{id} OR player2_id= #{id} ) AND active=0'

end
