class Fbuser < ActiveRecord::Base
	belongs_to :playing_as,  :class_name => 'Player', :foreign_key => 'playing_as'

	#using the metaphor of 'installing the user'
	def self.install( fb_user_id )
		p = Player.create( :name => "Facebook #{fb_user_id}" )
		Fbuser.create( :facebook_user_id => fb_user_id, :playing_as => p ) #returns what was created

		# give them a game with me 
		m = Match.create( :player1 => p, :player2 => Player.find(1) )
	end
end
