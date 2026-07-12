class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.boolean :available, default: false, null: false
      t.integer :status, default: 0, null: false
      t.date :released_on

      t.timestamps
    end
  end
end
