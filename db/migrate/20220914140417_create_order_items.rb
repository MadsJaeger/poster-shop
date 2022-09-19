class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true, null: false
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer    :amount, default: 0, null: false
      t.decimal    :price, scale: 2, precision: 8, null: false
      t.virtual    :value, type: :decimal, scale: 2, precision: 10, stored: true, 
        as: 'amount * price'
      t.timestamps
    end

    add_index :order_items, %i[order_id user_id product_id], unique: true
  end
end
