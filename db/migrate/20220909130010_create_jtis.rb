class CreateJtis < ActiveRecord::Migration[7.0]
  def change
    create_table :jtis, primary_key: :jti, id: :string do |t|
      t.datetime   :exp, null: false, comment: 'Expiration of JWT'
      t.references :user, null: false, index: true
      t.string     :agent, null: false, comment: 'HTTP agent of the user when issued'
      t.timestamps
    end
  end
end
