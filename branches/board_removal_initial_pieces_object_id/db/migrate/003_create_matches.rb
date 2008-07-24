class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.column :player1_id, :int, :null=>false
      t.column :player2_id, :int, :null=>false
      
      t.column :active, :int, :default=>1

      #stores serialized version of pieces
      t.column :pieces, :text

      t.column :result, :string, :limit => 10
      t.column :winning_player, :int

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
