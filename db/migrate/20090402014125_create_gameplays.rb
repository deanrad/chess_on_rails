class CreateGameplays < ActiveRecord::Migration
  def self.up
    create_table :gameplays do |t|
      t.integer :player_id, :null => false
      t.integer :match_id, :null => false
      t.boolean :black, :default => false
      t.string  :move_queue, :limit => 20
      t.boolean :email_notify, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :gameplays
  end
end
