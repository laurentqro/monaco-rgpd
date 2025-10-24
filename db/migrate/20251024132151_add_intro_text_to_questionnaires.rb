class AddIntroTextToQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    add_column :questionnaires, :intro_text, :text
  end
end
