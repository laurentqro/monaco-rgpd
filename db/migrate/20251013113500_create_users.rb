class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :avatar_url
      t.integer :role, default: 0, null: false
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
