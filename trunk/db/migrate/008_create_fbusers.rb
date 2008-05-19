class CreateFbusers < ActiveRecord::Migration
  def self.up
    create_table :fbusers do |t|
      t.integer :playing_as

      t.timestamps
    end

    execute("alter table fbusers modify id bigint")
  end

  def self.down
    drop_table :fbusers
  end
end
