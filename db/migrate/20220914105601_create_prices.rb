class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices do |t|
      t.references :product, null: false, foreign_key: true
      t.datetime   :from, null: false
      t.decimal    :value, scale: 2, precision: 8, null: false
      t.timestamps
    end

    add_index :prices, %I[product_id from], unique: true
  end
end
