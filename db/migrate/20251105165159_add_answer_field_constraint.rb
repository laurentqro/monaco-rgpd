class AddAnswerFieldConstraint < ActiveRecord::Migration[8.1]
  def up
    # Ensure columns exist before adding constraint (in case AddSeparateAnswerFields was empty)
    unless column_exists?(:answers, :answer_choice_id)
      add_column :answers, :answer_choice_id, :bigint
      add_column :answers, :answer_text, :text
      add_column :answers, :answer_rating, :integer
      add_column :answers, :answer_number, :decimal, precision: 10, scale: 2
      add_column :answers, :answer_date, :date
      add_column :answers, :answer_boolean, :boolean

      add_index :answers, :answer_choice_id
      add_index :answers, :answer_rating
      add_index :answers, [ :question_id, :answer_choice_id ],
                name: "index_answers_on_question_and_choice",
                where: "answer_choice_id IS NOT NULL"

      add_foreign_key :answers, :answer_choices, column: :answer_choice_id
    end

    # Add constraint if it doesn't already exist
    constraint_exists = connection.select_value(<<-SQL.squish)
      SELECT COUNT(*)
      FROM pg_constraint
      WHERE conname = 'exactly_one_answer_field'
    SQL

    if constraint_exists.to_i == 0
      execute <<-SQL
        ALTER TABLE answers
        ADD CONSTRAINT exactly_one_answer_field CHECK (
          (
            (CASE WHEN answer_choice_id IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN answer_text IS NOT NULL AND answer_text != '' THEN 1 ELSE 0 END) +
            (CASE WHEN answer_rating IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN answer_number IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN answer_date IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN answer_boolean IS NOT NULL THEN 1 ELSE 0 END)
          ) = 1
        )
      SQL
    end
  end

  def down
    execute "ALTER TABLE answers DROP CONSTRAINT IF EXISTS exactly_one_answer_field"
  end
end
