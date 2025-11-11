class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :response, null: true, foreign_key: true
      t.references :questionnaire, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :metadata, default: {}, null: false

      t.timestamps

      t.index [ :account_id, :created_at ]
    end
  end
end
