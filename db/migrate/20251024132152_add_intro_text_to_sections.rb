class AddIntroTextToSections < ActiveRecord::Migration[8.0]
  def change
    add_column :sections, :intro_text, :text
  end
end
