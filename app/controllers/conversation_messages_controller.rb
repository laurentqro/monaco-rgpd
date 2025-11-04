class ConversationMessagesController < ApplicationController
  def create
    conversation = Current.account.conversations.find(params[:conversation_id])
    orchestrator = ConversationOrchestrator.new(conversation)

    response = orchestrator.process_user_message(message_params[:content])

    render json: {
      message: conversation.messages.last,
      next_action: response[:next_action]
    }
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
