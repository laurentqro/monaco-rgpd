require "test_helper"

class ComplianceScorerTest < ActiveSupport::TestCase
  test "should calculate overall score from answers" do
    response = responses(:completed_response)
    scorer = ComplianceScorer.new(response)

    assessment = scorer.calculate

    assert assessment.persisted?
    assert assessment.overall_score > 0
    assert_not_nil assessment.risk_level
  end

  test "should calculate compliance area scores" do
    response = responses(:completed_response)
    scorer = ComplianceScorer.new(response)

    assessment = scorer.calculate

    assert assessment.compliance_area_scores.any?
  end
end
