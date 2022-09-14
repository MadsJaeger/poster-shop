class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string   :name, default: nil
      t.string   :email, null: false
      t.boolean  :admin, default: false
      t.string   :password_digest, null: false
      t.string   :password_reset_token, comment: 'When locked or password forgot'
      t.integer  :password_attempts, default: 0, comment: 'Count of failed attempts signing in with password'
      t.datetime :locked_at
      t.integer  :max_tokens, default: 5, unsigned: true, comment: 'Max allowed simultaneous tokens that can be issued'
      t.integer  :token_duration, default: 900, unsigned: true, comment: 'Default duration of token in seconds'
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
