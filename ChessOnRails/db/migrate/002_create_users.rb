class CreateUsers < ActiveRecord::Migration
  def self.up
	  create_table :users do |t|
		  t.column :email, :string, :limit=>50
		  t.column :playing_as, :int
		  
		  t.column :security_phrase , :string, :limit=>200
		  t.column :security_phrase_hint , :string, :limit=>200
		  
		  t.timestamps
	  end
	
  end

  def self.down
	  drop_table :users
  end
 
 end
