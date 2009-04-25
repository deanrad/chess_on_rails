class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      
      t.column :active, :int, :default => 1

      #an initial coordinate set in fen notation, if not the start of game
      t.column :start_pos, :string, :limit => 100
      t.column :result, :string, :limit => 10
      t.column :winning_player, :int
      t.column :name, :string, :limit => 100

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
