require "test_helper"

class ResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
    @response = responses(:one)
    @questionnaire = questionnaires(:compliance)
  end

  test "should get index" do
    get responses_url
    assert_response :success
  end

  test "should create response" do
    assert_difference("Response.count") do
      post questionnaire_responses_url(@questionnaire)
    end
    assert_redirected_to questionnaire_response_path(@questionnaire, Response.last)
  end

  test "should get show" do
    get questionnaire_response_url(@questionnaire, @response)
    assert_response :success
  end

  test "should update response" do
    patch questionnaire_response_url(@questionnaire, @response), params: { response: { status: :in_progress } }
    assert_response :no_content
  end

  test "should complete response" do
    response = @response
    post complete_response_url(response)
    assert_redirected_to dashboard_path
    assert_equal "Évaluation terminée ! Votre score de conformité a été calculé.", flash[:notice]
    response.reload
    assert_equal "completed", response.status
    assert_not_nil response.completed_at
    assert_not_nil response.compliance_assessment
  end

  test "should get results" do
    @response.update!(status: :completed, completed_at: Time.current)
    get results_response_url(@response)
    assert_response :success
  end

  test "results shows waitlist form when response requires waitlist" do
    # Setup: Add a waitlist-triggering answer
    response_model = @response
    question = questions(:one)
    choice = question.answer_choices.create!(
      choice_text: "Association",
      order_index: 1,
      score: 0,
      triggers_waitlist: true,
      waitlist_feature_key: "association"
    )
    response_model.answers.create!(question: question, answer_choice: choice)

    get results_response_url(response_model)

    assert_response :success
    # The controller should render ResultsWithWaitlist when waitlist is required
    assert response_model.requires_waitlist?, "Response should require waitlist"
  end

  test "results shows normal view when no waitlist required" do
    # Ensure no waitlist-triggering answers exist
    response_model = @response
    response_model.answers.destroy_all

    get results_response_url(response_model)

    assert_response :success
    assert_not response_model.requires_waitlist?, "Response should not require waitlist"
  end
end
