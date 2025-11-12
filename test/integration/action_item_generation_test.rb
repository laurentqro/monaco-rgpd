require "test_helper"

class ActionItemGenerationTest < ActiveSupport::TestCase
  test "action items are generated when compliance assessment is created" do
    response = responses(:one)

    # Create answers with varying compliance levels
    # Assuming questions exist in fixtures with compliance_area associations

    initial_count = ActionItem.count
    assessment = ComplianceScorer.new(response).calculate

    # Action items should be generated (at least 1)
    assert ActionItem.count > initial_count, "Expected action items to be generated"

    # Verify the action items are associated with the assessment
    action_items = ActionItem.where(actionable: assessment)
    assert action_items.exists?, "Action items should be associated with the assessment"

    # Verify action items have correct attributes
    action_items.each do |item|
      assert_equal response.account, item.account
      assert_equal assessment, item.actionable
      assert_equal "assessment", item.source
      assert item.title.present?
    end
  end
end
