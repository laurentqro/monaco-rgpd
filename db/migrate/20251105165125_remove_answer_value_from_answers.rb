class RemoveAnswerValueFromAnswers < ActiveRecord::Migration[8.1]
  def up
    remove_column :answers, :answer_value if column_exists?(:answers, :answer_value)
  end

  def down
    add_column :answers, :answer_value, :jsonb, default: {}, null: false
  end
end
