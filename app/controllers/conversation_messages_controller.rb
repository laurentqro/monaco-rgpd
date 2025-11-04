class ConversationMessagesController < ApplicationController
  def create
    conversation = Current.account.conversations.find(params[:conversation_id])
    orchestrator = ConversationOrchestrator.new(conversation)

    response = orchestrator.process_user_message(message_params[:content])

    assistant_message = conversation.messages.last

    render json: {
      message: {
        id: assistant_message.id,
        role: assistant_message.role, # Returns string name like "assistant", not integer
        content: assistant_message.content,
        extracted_data: assistant_message.extracted_data,
        created_at: assistant_message.created_at
      },
      next_action: response[:next_action]
    }
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
