require "test_helper"

class CalculateComplianceScoreJobTest < ActiveJob::TestCase
  test "should calculate compliance score for response" do
    response = responses(:one)

    assert_enqueued_with(job: CalculateComplianceScoreJob, args: [response.id]) do
      CalculateComplianceScoreJob.perform_later(response.id)
    end
  end
end
