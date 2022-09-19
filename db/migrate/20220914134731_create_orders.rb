class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer    :size, default: 0, null: false, comment: 'Count of items in order'
      t.decimal    :value, default: 0, scale: 2, precision: 10, null: false, comment: 'Total value of order'
      t.timestamp  :checkout_at, comment: 'User lastly asked for checkout at'
      t.timestamp  :confirmed_at, comment: 'User confirmed checkout at'

      t.timestamps
    end
  end
end
