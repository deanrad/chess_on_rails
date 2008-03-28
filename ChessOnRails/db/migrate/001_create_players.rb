class CreatePlayers < ActiveRecord::Migration
	def self.up

		create_table :players do |t|
			t.column :name, :string, :limit=>20
            t.column :current_match, :int         
		end

		add_index :players, [:name], :unique=>true

        #todo: migrate to rake db:seed fixtures in db\fixtures
		create_players
		
	end

	def self.down
		drop_table :players
	end

	def self.create_players
		#nice syntax
        p = Player.new :name=>"Dean"
		p.save()
		
		#more verbose, gets the job done
		p = Player.new
		p.name = "Maria"
		p.save()

        [ "Paul" ].each do |player_name|
            Player.new(:name=>player_name).save
        end

		#even this way of doing it repeats the hash keys :name, :win_loss several times
		#TODO: look into ways of only creating hash once and follow DRY principle !
	end
	
end
