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
    assert_redirected_to results_response_path(response)
    response.reload
    assert_equal "completed", response.status
    assert_not_nil response.completed_at
  end

  test "should get results" do
    @response.update!(status: :completed, completed_at: Time.current)
    get results_response_url(@response)
    assert_response :success
  end
end
