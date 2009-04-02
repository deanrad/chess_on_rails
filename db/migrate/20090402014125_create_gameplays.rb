class CreateGameplays < ActiveRecord::Migration
  def self.up
    create_table :gameplays do |t|
      t.integer :player_id, :null => false
      t.integer :match_id, :null => false
      t.boolean :black, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :gameplays
  end
end
