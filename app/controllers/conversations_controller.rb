class ConversationsController < ApplicationController
  def create
    questionnaire = Questionnaire.find(params[:questionnaire_id])

    # Create or find response
    response = Current.account.responses.find_or_create_by!(
      questionnaire: questionnaire,
      respondent: Current.user
    )

    orchestrator = ConversationOrchestrator.start(
      questionnaire: questionnaire,
      account: Current.account
    )

    # Link conversation to response
    orchestrator.conversation.update!(response: response)

    redirect_to conversation_path(orchestrator.conversation)
  end

  def show
    conversation = Current.account.conversations.find(params[:id])
    render_conversation(conversation)
  end

  private

  def render_conversation(conversation)
    render inertia: "Chat/Show",
      props: {
        conversation: conversation.as_json(include: :messages),
        questionnaire: conversation.questionnaire.as_json(
          include: {
            sections: {
              include: :questions
            }
          }
        )
      }
  end
end
