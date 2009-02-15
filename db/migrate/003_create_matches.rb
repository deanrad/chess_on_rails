class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.column :player1_id, :int, :null => false
      t.column :player2_id, :int, :null => false
      
      t.column :active, :int, :default => 1

      #an initial coordinate set in fen notation, if not the start of game
      t.column :start_pos, :text 
      t.column :result, :text
      t.column :winning_player, :int

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
