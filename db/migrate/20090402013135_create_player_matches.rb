class CreatePlayerMatches < ActiveRecord::Migration
  def self.up
    create_table :player_matches do |t|
      t.int :player_id
      t.int :match_id
      t.bool :black_side

      t.timestamps
    end
  end

  def self.down
    drop_table :player_matches
  end
end
