class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :amount
      t.references :price, null: false, foreign_key: true

      t.timestamps
    end

    add_index :order_items, %i[order_id user_id product_id], unique: true
  end
end
