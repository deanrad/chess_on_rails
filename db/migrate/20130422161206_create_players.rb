class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :id
      t.string :name
      t.boolean :active

      t.timestamps
    end
  end
end
