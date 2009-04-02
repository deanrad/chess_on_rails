class CreateGamePlays < ActiveRecord::Migration
  def self.up
    create_table :game_plays do |t|
      t.integer :player_id, :null => false
      t.integer :match_id, :null => false
      t.boolean :black_side, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :game_plays
  end
end
