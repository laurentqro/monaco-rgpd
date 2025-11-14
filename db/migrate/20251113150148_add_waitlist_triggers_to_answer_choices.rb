class AddWaitlistTriggersToAnswerChoices < ActiveRecord::Migration[8.1]
  def change
    add_column :answer_choices, :triggers_waitlist, :boolean, default: false, null: false
    add_column :answer_choices, :waitlist_feature_key, :string

    add_index :answer_choices, :waitlist_feature_key
  end
end
