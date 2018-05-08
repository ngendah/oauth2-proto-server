class CreateJwts < ActiveRecord::Migration[5.2]
  def change
    create_table :jwts do |t|
      t.belongs_to :client
      t.string :subject
      t.string :public_key, null: false, size: 1024
      t.timestamps
    end
  end
end
