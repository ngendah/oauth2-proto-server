class CreateScopes < ActiveRecord::Migration[5.2]
  def change
    create_table :scopes do |t|
      t.string :scope, null: false, index: true
      t.boolean :is_default, default: false
      t.timestamps
    end
  end
end
