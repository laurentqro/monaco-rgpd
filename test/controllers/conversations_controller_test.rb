require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
    @questionnaire = questionnaires(:compliance)
  end

  test "creates new conversation" do
    assert_difference "Conversation.count", 1 do
      post conversations_path, params: { questionnaire_id: @questionnaire.id }
    end

    conversation = Conversation.last
    assert_redirected_to conversation_path(conversation)
  end

  test "shows existing conversation" do
    conversation = conversations(:active)

    get conversation_path(conversation)

    assert_response :success
  end

  test "requires authentication" do
    sign_out
    post conversations_path, params: { questionnaire_id: @questionnaire.id }

    assert_redirected_to new_session_path
  end

  private

  def sign_out
    delete session_path
  end
end
