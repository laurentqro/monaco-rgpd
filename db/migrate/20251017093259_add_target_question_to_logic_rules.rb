class AddTargetQuestionToLogicRules < ActiveRecord::Migration[8.0]
  def change
    add_reference :logic_rules, :target_question, foreign_key: { to_table: :questions }, index: true
  end
end
