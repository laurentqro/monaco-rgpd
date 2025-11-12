require "test_helper"

class ActionItemGeneratorTest < ActiveSupport::TestCase
  def setup
    # Clean up action items and area scores before each test to ensure isolation
    ActionItem.destroy_all
    ComplianceAreaScore.destroy_all
  end

  test "generates action items from compliance assessment" do
    assessment = compliance_assessments(:one)
    # Create area scores with varying percentages
    area1 = compliance_areas(:security)
    area2 = compliance_areas(:lawfulness)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area1,
      score: 45,
      max_score: 100
    )

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area2,
      score: 85,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    assert_difference "ActionItem.count", 1 do
      generator.generate
    end

    action_item = ActionItem.last
    assert_equal assessment.account, action_item.account
    assert_equal assessment, action_item.actionable
    assert_equal "assessment", action_item.source
    assert action_item.title.present?
  end

  test "generates high priority items for scores below 60%" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 30,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)
    generator.generate

    action_item = ActionItem.last
    assert_equal "high", action_item.priority
  end

  test "generates medium priority items for scores 60-79%" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 70,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)
    generator.generate

    action_item = ActionItem.last
    assert_equal "medium", action_item.priority
  end

  test "does not generate items for scores 80% and above" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 85,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    assert_no_difference "ActionItem.count" do
      generator.generate
    end
  end

  test "does not duplicate action items on multiple calls" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:security)

    ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 50,
      max_score: 100
    )

    generator = ActionItemGenerator.new(assessment)

    generator.generate
    first_count = ActionItem.count

    generator.generate
    assert_equal first_count, ActionItem.count
  end
end
