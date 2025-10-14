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
end
