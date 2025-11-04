class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.integer :role, null: false
      t.text :content, null: false
      t.jsonb :extracted_data, default: {}, null: false
      t.references :question, null: true, foreign_key: true

      t.timestamps

      t.index [:conversation_id, :created_at]
    end
  end
end
