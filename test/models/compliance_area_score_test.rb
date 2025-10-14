require "test_helper"

class ComplianceAreaScoreTest < ActiveSupport::TestCase
  test "should calculate percentage" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 82.5,
      max_score: 100.0
    )

    assert_equal 82.5, area_score.percentage
  end

  test "should require score" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = ComplianceAreaScore.new(
      compliance_assessment: assessment,
      compliance_area: area,
      max_score: 100.0
    )

    assert_not area_score.valid?
    assert area_score.errors[:score].any?
  end

  test "should require max_score" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = ComplianceAreaScore.new(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 80.0
    )

    assert_not area_score.valid?
    assert area_score.errors[:max_score].any?
  end

  test "should belong to compliance assessment and area" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = ComplianceAreaScore.create!(
      compliance_assessment: assessment,
      compliance_area: area,
      score: 75.0,
      max_score: 100.0
    )

    assert_equal assessment, area_score.compliance_assessment
    assert_equal area, area_score.compliance_area
  end
end
