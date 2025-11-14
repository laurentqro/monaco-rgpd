class CreateWaitlistEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :waitlist_entries do |t|
      t.string :email, null: false
      t.references :response, null: false, foreign_key: true
      t.jsonb :features_needed, default: [], null: false

      t.boolean :notified, default: false, null: false
      t.datetime :notified_at

      t.timestamps
    end

    add_index :waitlist_entries, :email
    add_index :waitlist_entries, :features_needed, using: :gin
    add_index :waitlist_entries, [ :notified, :created_at ]
  end
end
