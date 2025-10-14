class AddExitQuestionnaireActionToLogicRules < ActiveRecord::Migration[8.0]
  def up
    # Add exit_message column to store the message shown when exiting
    add_column :logic_rules, :exit_message, :text
  end

  def down
    remove_column :logic_rules, :exit_message
  end
end
