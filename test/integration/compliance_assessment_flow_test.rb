require "test_helper"

class ComplianceAssessmentFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
  end

  test "complete compliance assessment flow" do
    # 1. Start questionnaire
    questionnaire = questionnaires(:compliance)

    post questionnaire_responses_path(questionnaire)
    assert_response :redirect

    response = @account.responses.last
    assert_equal "in_progress", response.status

    # 2. Answer questions
    question = questions(:one)

    post response_answers_path(response), params: {
      answer: {
        question_id: question.id,
        answer_value: { choice_id: answer_choices(:yes_choice).id }
      }
    }
    assert_response :created

    assert_equal 1, response.answers.count

    # 3. Complete questionnaire
    post complete_response_path(response)
    assert_response :redirect

    response.reload
    assert_equal "completed", response.status
    assert_not_nil response.completed_at

    # 4. Verify compliance assessment was calculated synchronously
    assert_not_nil response.compliance_assessment
    assert response.compliance_assessment.overall_score >= 0

    # 5. Verify document generation job enqueued
    assert_enqueued_jobs 1, only: GenerateDocumentsJob
  end
end
