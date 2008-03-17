class CreateUsers < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.column :email, :string, :limit=>50
		  t.column :playing_as, :int
		  
		  t.column :security_phrase , :string, :limit=>200
		  t.column :security_phrase_hint , :string, :limit=>200
		  
		  t.timestamps
	  end
	
	  create_users
  end

  def self.down
	  drop_table :users
  end
  
  def self.create_users
	u = User.new :email=>'chicagogrooves@gmail.com'
	u.playing_as = Player.find_by_id 1
	u.security_phrase = '9'
	u.security_phrase_hint = 'Which version of Chessmaster do you own?'
	u.save!
  end
end
