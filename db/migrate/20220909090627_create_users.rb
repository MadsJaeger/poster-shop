class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, default: nil
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :max_tokens, default: 5, unsigned: true
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
