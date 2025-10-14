require "test_helper"

class ComplianceAssessmentTest < ActiveSupport::TestCase
  test "should calculate risk level based on score" do
    response = responses(:one)

    assessment = ComplianceAssessment.create!(
      response: response,
      account: response.account,
      overall_score: 75.0,
      max_possible_score: 100.0,
      status: :completed
    )

    assert_equal "attention_required", assessment.risk_level
  end

  test "should have compliance area scores" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = assessment.compliance_area_scores.create!(
      compliance_area: area,
      score: 82.0,
      max_score: 100.0
    )

    assert_equal 82.0, area_score.score
  end

  test "should calculate compliant risk level for high scores" do
    response = responses(:one)

    assessment = ComplianceAssessment.create!(
      response: response,
      account: response.account,
      overall_score: 90.0,
      max_possible_score: 100.0,
      status: :completed
    )

    assert_equal "compliant", assessment.risk_level
  end

  test "should calculate non_compliant risk level for low scores" do
    response = responses(:one)

    assessment = ComplianceAssessment.create!(
      response: response,
      account: response.account,
      overall_score: 45.0,
      max_possible_score: 100.0,
      status: :completed
    )

    assert_equal "non_compliant", assessment.risk_level
  end

  test "should belong to response and account" do
    assessment = compliance_assessments(:one)

    assert_not_nil assessment.response
    assert_not_nil assessment.account
  end

  test "should have many compliance area scores" do
    assessment = compliance_assessments(:one)

    assert_respond_to assessment, :compliance_area_scores
  end
end
