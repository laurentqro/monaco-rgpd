require "test_helper"

class AiChatButtonsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:owner)
    @account = @user.account
    sign_in_as @user
    @questionnaire = questionnaires(:compliance)

    # Mock AI response with suggested_buttons
    @mock_response_with_buttons = {
      message: "Votre organisation est-elle établie à Monaco ?",
      suggested_buttons: {
        question_id: 22,
        buttons: [
          { choice_id: 1, label: "Oui" },
          { choice_id: 2, label: "Non" }
        ]
      },
      extracted_data: { answers: [] },
      next_action: "ask_next_question"
    }
  end

  test "AI includes suggested_buttons in response" do
    # Start conversation
    post conversations_path, params: { questionnaire_id: @questionnaire.id }
    conversation = Conversation.last

    # Mock AI to return buttons
    ConversationOrchestrator.class_eval do
      define_method(:get_ai_response) do |_message|
        {
          message: "Votre organisation est-elle établie à Monaco ?",
          suggested_buttons: {
            question_id: 22,
            buttons: [
              { choice_id: 1, label: "Oui" },
              { choice_id: 2, label: "Non" }
            ]
          },
          extracted_data: { answers: [] },
          next_action: "ask_next_question"
        }
      end
    end

    # Send user message
    post conversation_messages_path(conversation),
      params: { message: { content: "Bonjour" } }

    assert_response :success
    response_data = JSON.parse(@response.body)

    # Verify suggested_buttons are in response
    assert response_data["message"]["extracted_data"]["suggested_buttons"].present?
    assert_equal 22, response_data["message"]["extracted_data"]["suggested_buttons"]["question_id"]
    assert_equal 2, response_data["message"]["extracted_data"]["suggested_buttons"]["buttons"].length
  end

  test "button click sends choice label as user message" do
    # This is tested client-side (button click → handleSendMessage)
    # Backend just receives text message, same as typed input
    # Verifying the flow works end-to-end

    conversation = conversations(:active)

    ConversationOrchestrator.class_eval do
      define_method(:get_ai_response) do |message|
        # When user sends "Oui" (from button click)
        if message == "Oui"
          {
            message: "Parfait! Passons à la question suivante.",
            extracted_data: {
              answers: [ {
                question_id: 22,
                answer_type: "yes_no",
                value: "Oui",
                confidence: 1.0
              } ]
            },
            next_action: "ask_next_question"
          }
        else
          {
            message: "Merci pour votre réponse.",
            extracted_data: { answers: [] },
            next_action: "ask_next_question"
          }
        end
      end
    end

    # Simulate button click (frontend sends button label as message)
    post conversation_messages_path(conversation),
      params: { message: { content: "Oui" } }

    assert_response :success
    response_data = JSON.parse(@response.body)

    # Verify AI processed the button selection
    assert_includes response_data["message"]["content"], "Parfait"
  end
end
