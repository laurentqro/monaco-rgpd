class AddAnswerFieldConstraint < ActiveRecord::Migration[8.1]
  def up
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

  def down
    execute "ALTER TABLE answers DROP CONSTRAINT exactly_one_answer_field"
  end
end
