class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :uid, null: false, index: true, unique: true
      t.string :secret, null: false, size: 255
      t.string :redirect_url, size: 255
      t.string :grant_types, array: true
      t.integer :scope, array: true
      t.belongs_to :user
      t.timestamps
    end
  end
end
