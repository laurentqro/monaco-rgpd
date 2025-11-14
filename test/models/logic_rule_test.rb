require "test_helper"

class LogicRuleTest < ActiveSupport::TestCase
  test "supports exit_to_waitlist action" do
    rule = LogicRule.new(
      source_question: questions(:one),
      condition_type: :equals,
      condition_value: "1",
      action: :exit_to_waitlist
    )

    assert rule.valid?
    assert rule.action_exit_to_waitlist?
  end
end
