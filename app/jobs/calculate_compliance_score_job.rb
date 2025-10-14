class CalculateComplianceScoreJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = Response.find(response_id)
    scorer = ComplianceScorer.new(response)
    scorer.calculate
  end
end
