class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.column :name, :string, :limit => 20
    end

    add_index :players, [:name], :unique => true
  end

  def self.down
    drop_table :players
  end

end
