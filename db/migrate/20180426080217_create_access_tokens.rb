class CreateAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :access_tokens do |t|
      t.string :token, index: true, unique: true, null: false, size: 175
      t.timestamp :expires, null: false
      t.integer :scopes, array: true
      t.boolean :refresh, default: false
      t.boolean :deleted, default: false
      t.string :grant_type, null: false, size: 80
      t.timestamps
    end
  end
end
