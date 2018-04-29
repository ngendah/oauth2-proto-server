class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :uid, null: false, index: true, unique: true
      t.string :secret, null: false
      t.string :redirect_uri
      t.string :grant_types, array: true, default: []
      t.integer :scope, array: true, default: []
      t.belongs_to :user
      t.timestamps
    end
  end
end
