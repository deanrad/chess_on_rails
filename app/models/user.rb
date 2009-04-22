class User < ActiveRecord::Base
  belongs_to :playing_as, :class_name => "Player", :foreign_key => "playing_as"

  # creates a user and the corresponding player, passing a hash of options to each 
  def self.create_with_player( user_opts, player_opts )
    u = User.create( user_opts )
    p = Player.create( player_opts )
    u.playing_as = p
    u.save!
    u
  end

end
