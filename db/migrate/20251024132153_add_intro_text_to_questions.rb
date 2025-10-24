class AddIntroTextToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :intro_text, :text
  end
end
