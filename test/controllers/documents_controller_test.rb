require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user

    @account.update(
      address: "12 Avenue des Spélugues",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )
  end

  test "index requires authentication" do
    Session.destroy_all

    get documents_path

    assert_redirected_to new_session_path
  end

  test "index renders documents page" do
    get documents_path

    assert_response :success
  end

  test "generate_privacy_policy returns error when account incomplete" do
    @account.update(address: nil)

    post generate_privacy_policy_documents_path, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "incomplete_profile", json["error"]
  end

  test "generate_privacy_policy returns error when no completed questionnaire" do
    # Ensure no completed responses exist
    @account.responses.destroy_all

    post generate_privacy_policy_documents_path, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "no_completed_questionnaire", json["error"]
  end

  test "generate_privacy_policy downloads PDF when account complete" do
    # Create completed response
    response = @account.responses.create!(
      questionnaire: questionnaires(:compliance),
      respondent: @user,
      status: :completed
    )

    post generate_privacy_policy_documents_path

    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert_match /politique_confidentialite/, @response.headers["Content-Disposition"]
  end
end
