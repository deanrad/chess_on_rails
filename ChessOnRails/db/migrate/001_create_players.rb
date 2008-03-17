class CreatePlayers < ActiveRecord::Migration
	def self.up
		#tried to steal the t away from the block below into this variable (didn't work)
		#tref = ActiveRecord::ConnectionAdapters::TableDefinition
		create_table :players do |t|
			t.column :name, :string, :limit=>20
			
			#temporary property - in future will be determined by business logic
			t.string :win_loss, :limit=>7, :default=>"0/0" 
		end
		add_index :players, [:name], :unique=>true
		
		create_players
		
	end

	def self.down
		drop_table :players
	end

	def self.create_players
		#nice syntax
		p = Player.new :name=>"Dean", :win_loss=>"5/5"
		p.save()
		
		#more verbose, gets the job done
		p = Player.new
		p.name = "Maria"
		p.win_loss = "5/0"
		p.save()
		
		p = Player.new :name=>"Paul", :win_loss=>"5/5"
		p.save()
		
		p= Player.new :name=>"Jones", :win_loss=>"0/5"
		p.save()
		
		#even this way of doing it repeats the hash keys :name, :win_loss several times
		#TODO: look into ways of only creating hash once and follow DRY principle !
	end
	
end