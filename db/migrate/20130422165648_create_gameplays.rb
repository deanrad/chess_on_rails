class CreateGameplays < ActiveRecord::Migration
  def change
    create_table :gameplays do |t|
      t.integer :player_id
      t.integer :match_id

      t.timestamps
    end
  end
end
