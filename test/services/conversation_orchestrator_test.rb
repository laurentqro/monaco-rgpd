require "test_helper"
require "ostruct"

class ConversationOrchestratorTest < ActiveSupport::TestCase
  test "starts new conversation with welcome message" do
    questionnaire = questionnaires(:compliance)
    account = accounts(:basic)

    orchestrator = ConversationOrchestrator.start(
      questionnaire: questionnaire,
      account: account
    )

    assert orchestrator.conversation.persisted?
    assert_equal 1, orchestrator.conversation.messages.count
    assert orchestrator.conversation.messages.first.role_assistant?
  end

  test "processes user message and creates response" do
    conversation = conversations(:active)
    orchestrator = ConversationOrchestrator.new(conversation)
    initial_count = conversation.messages.count

    # Mock the get_ai_response method directly
    def orchestrator.get_ai_response(_message)
      {
        message: "Merci pour cette information.",
        extracted_data: { answers: [] },
        next_action: "ask_next_question"
      }
    end

    response = orchestrator.process_user_message("Oui, nous avons un DPO")

    assert_equal initial_count + 2, conversation.messages.count
    assert_equal "Oui, nous avons un DPO", conversation.messages.by_user.last.content
    assert_equal "Merci pour cette information.", conversation.messages.by_assistant.last.content
  end

  test "parses suggested_buttons from AI response" do
    conversation = conversations(:active)
    orchestrator = ConversationOrchestrator.new(conversation)

    # Mock AI response with suggested_buttons
    def orchestrator.get_ai_response(_message)
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

    orchestrator.process_user_message("Test")

    assistant_message = conversation.messages.by_assistant.last
    assert assistant_message.extracted_data["suggested_buttons"].present?
    assert_equal 22, assistant_message.extracted_data["suggested_buttons"]["question_id"]
    assert_equal 2, assistant_message.extracted_data["suggested_buttons"]["buttons"].length
  end

  test "handles missing suggested_buttons gracefully" do
    conversation = conversations(:active)
    orchestrator = ConversationOrchestrator.new(conversation)

    # Mock AI response WITHOUT suggested_buttons
    def orchestrator.get_ai_response(_message)
      {
        message: "Pouvez-vous me donner plus de détails ?",
        extracted_data: { answers: [] },
        next_action: "clarify"
      }
    end

    orchestrator.process_user_message("Test")

    assistant_message = conversation.messages.by_assistant.last
    assert_nil assistant_message.extracted_data["suggested_buttons"]
  end
end
