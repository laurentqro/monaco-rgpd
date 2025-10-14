class CalculateComplianceScoreJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = Response.find(response_id)
    scorer = ComplianceScorer.new(response)
    scorer.calculate

    # Trigger document generation after assessment is calculated
    GenerateDocumentsJob.perform_later(response_id)
  end
end
