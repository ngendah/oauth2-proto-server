class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, null: false, index: true, unique: true
      t.string :password_digest, null: false
      t.integer :scope, array: true
      t.timestamps
    end

    create_table :access_tokens_users, id: false do |t|
      t.belongs_to :access_token, index: true
      t.belongs_to :user, index: true
    end
  end
end
