class DashboardController < ApplicationController
  def show
    latest_response = Current.account.responses
      .includes(:compliance_assessment)
      .completed
      .order(created_at: :desc)
      .first

    # Get the published questionnaire (assuming there's only one published at a time)
    published_questionnaire = Questionnaire.published.first

    render inertia: "Dashboard/Show", props: {
      latest_assessment: latest_response&.compliance_assessment ? assessment_props(latest_response.compliance_assessment) : nil,
      latest_response_id: latest_response&.id,
      responses: Current.account.responses.order(created_at: :desc).limit(5).map { |r| response_summary_props(r) },
      questionnaire_id: published_questionnaire&.id
    }
  end

  private

  def assessment_props(assessment)
    {
      overall_score: assessment.overall_score.round(1),
      max_possible_score: assessment.max_possible_score,
      risk_level: assessment.risk_level,
      created_at: assessment.created_at,
      compliance_area_scores: assessment.compliance_area_scores.includes(:compliance_area).map do |cas|
        {
          area_name: cas.compliance_area.name,
          area_code: cas.compliance_area.code,
          score: cas.score.round(1),
          max_score: cas.max_score,
          percentage: cas.percentage
        }
      end
    }
  end

  def response_summary_props(response)
    {
      id: response.id,
      created_at: response.created_at,
      completed_at: response.completed_at,
      status: response.status
    }
  end
end
