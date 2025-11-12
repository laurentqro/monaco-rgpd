class CreateActionItems < ActiveRecord::Migration[8.1]
  def change
    create_table :action_items do |t|
      t.references :account, null: false, foreign_key: true
      t.references :actionable, polymorphic: true, null: false

      t.integer :source, null: false, default: 0
      t.integer :priority, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.integer :action_type, null: false, default: 0

      t.string :title, null: false
      t.text :description
      t.jsonb :action_params, default: {}

      t.datetime :due_at
      t.integer :impact_score
      t.datetime :snoozed_until

      t.timestamps
    end

    add_index :action_items, [ :account_id, :status ]
    add_index :action_items, [ :account_id, :priority ]
    add_index :action_items, :actionable_type
  end
end
