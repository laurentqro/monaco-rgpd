class CreateResponsesAndAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :respondent, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    create_table :answers do |t|
      t.references :response, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.jsonb :answer_value, default: {}
      t.decimal :calculated_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :responses, :status
    add_index :responses, [:account_id, :created_at]
    add_index :answers, [:response_id, :question_id], unique: true
  end
end
