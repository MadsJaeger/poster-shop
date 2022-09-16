class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string  :name, null: false
      t.text    :description
      t.decimal :price, scale: 2, precision: 8
      
      t.timestamps
    end

    add_index :products, :name
  end
end
