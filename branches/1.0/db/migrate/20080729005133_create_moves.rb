class CreateMoves < ActiveRecord::Migration
  def self.up
    create_table :moves do |t|
      t.integer :match_id
      t.integer :move_number
      t.string  :from_coord
      t.string  :to_coord
      t.string  :capture_coord
      t.string  :notation
      t.boolean :castled
      t.string  :promotion_piece

      t.timestamps
    end
  end

  def self.down
    drop_table :moves
  end
end
