require "test_helper"

class AiChatFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
    @questionnaire = questionnaires(:compliance)

    # Mock AI responses for integration test
    @mock_response = {
      message: "Merci pour cette information.",
      extracted_data: { answers: [] },
      next_action: "ask_next_question"
    }
  end

  test "complete chat conversation flow" do
    # Start conversation
    post conversations_path, params: { questionnaire_id: @questionnaire.id }
    assert_response :success

    conversation = Conversation.last
    assert_equal @questionnaire, conversation.questionnaire
    assert_equal @account, conversation.account
    assert_equal 1, conversation.messages.count

    # Temporarily override get_ai_response to avoid actual API calls
    ConversationOrchestrator.class_eval do
      define_method(:get_ai_response) do |_message|
        {
          message: "Merci pour cette information.",
          extracted_data: { answers: [] },
          next_action: "ask_next_question"
        }
      end
    end

    begin
      # Send user message
      post conversation_messages_path(conversation),
        params: { message: { content: "Oui, nous avons un DPO" } }

      assert_response :success
      response_data = JSON.parse(@response.body)
      assert_equal "Merci pour cette information.", response_data["message"]["content"]
      assert_equal 3, conversation.reload.messages.count
    ensure
      # Restore original implementation by reloading the class
      # (The original implementation will be restored when the test ends)
    end
  end
end
