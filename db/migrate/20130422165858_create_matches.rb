class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :id
      t.string :title
      t.boolean :active
      t.boolean :inprogress

      t.timestamps
    end
  end
end
