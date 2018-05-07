class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, null: false, index: true, unique: true
      t.string :password_digest, null: false
      t.integer :scope, array: true
      t.timestamps
    end
  end
end
