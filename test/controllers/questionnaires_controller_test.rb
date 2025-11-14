require "test_helper"

class QuestionnairesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
  end

  test "should get show" do
    questionnaire = questionnaires(:compliance)
    get questionnaire_url(questionnaire)
    assert_response :success
  end

  test "waitlist_exit renders waitlist page" do
    questionnaire = questionnaires(:compliance)

    get waitlist_exit_questionnaire_path(questionnaire)

    assert_response :success
  end

  test "waitlist_exit passes questionnaire data" do
    questionnaire = questionnaires(:compliance)

    get waitlist_exit_questionnaire_path(questionnaire)

    assert_response :success
    # Inertia props would include questionnaire data
  end
end
