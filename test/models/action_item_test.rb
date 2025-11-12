require "test_helper"

class ActionItemTest < ActiveSupport::TestCase
  test "valid action item" do
    action_item = ActionItem.new(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :medium,
      status: :pending,
      action_type: :update_treatment,
      title: "Add encryption to Customer Data treatment",
      description: "Implement encryption for customer personal data",
      action_params: { treatment_id: 1 },
      due_at: 7.days.from_now,
      impact_score: 15
    )
    assert action_item.valid?
  end

  test "requires account" do
    action_item = ActionItem.new(
      actionable: compliance_assessments(:one),
      source: :assessment,
      title: "Test"
    )
    assert_not action_item.valid?
    assert action_item.errors[:account].present?
  end

  test "requires title" do
    action_item = ActionItem.new(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment
    )
    assert_not action_item.valid?
    assert action_item.errors[:title].present?
  end

  test "requires source" do
    action_item = ActionItem.new(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      title: "Test",
      source: nil
    )
    assert_not action_item.valid?
    assert action_item.errors[:source].present?
  end

  test "belongs to actionable polymorphically" do
    action_item = action_items(:recommendation_one)
    assert_instance_of ComplianceAssessment, action_item.actionable
  end

  test "pending scope returns only pending items" do
    ActionItem.create!(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :high,
      status: :pending,
      action_type: :generate_document,
      title: "Pending item"
    )

    ActionItem.create!(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :low,
      status: :completed,
      action_type: :generate_document,
      title: "Completed item"
    )

    pending_items = ActionItem.pending
    assert pending_items.all? { |item| item.status == "pending" }
  end

  test "by_priority scope orders by priority descending" do
    low_item = ActionItem.create!(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :low,
      status: :pending,
      action_type: :generate_document,
      title: "Low priority"
    )

    critical_item = ActionItem.create!(
      account: accounts(:basic),
      actionable: compliance_assessments(:one),
      source: :assessment,
      priority: :critical,
      status: :pending,
      action_type: :generate_document,
      title: "Critical priority"
    )

    items = ActionItem.by_priority.to_a
    assert_equal critical_item.id, items.first.id
    assert_equal low_item.id, items.last.id
  end
end
