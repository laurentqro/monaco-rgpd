class AddSeparateAnswerFields < ActiveRecord::Migration[8.1]
  def change
    add_column :answers, :answer_choice_id, :bigint
    add_column :answers, :answer_text, :text
    add_column :answers, :answer_rating, :integer
    add_column :answers, :answer_number, :decimal, precision: 10, scale: 2
    add_column :answers, :answer_date, :date
    add_column :answers, :answer_boolean, :boolean

    add_index :answers, :answer_choice_id
    add_index :answers, :answer_rating
    add_index :answers, [:question_id, :answer_choice_id],
              name: "index_answers_on_question_and_choice",
              where: "answer_choice_id IS NOT NULL"

    add_foreign_key :answers, :answer_choices, column: :answer_choice_id
  end
end
