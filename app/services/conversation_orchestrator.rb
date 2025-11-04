# frozen_string_literal: true

class ConversationOrchestrator
  attr_reader :conversation

  def initialize(conversation)
    @conversation = conversation
    @client = Anthropic::Client.new
  end

  def self.start(questionnaire:, account:)
    conversation = Conversation.create!(
      questionnaire: questionnaire,
      account: account,
      status: :in_progress,
      started_at: Time.current
    )

    orchestrator = new(conversation)
    orchestrator.send_welcome_message
    orchestrator
  end

  def send_welcome_message
    welcome_text = build_welcome_message
    create_assistant_message(welcome_text)
  end

  def process_user_message(content)
    # Create user message
    user_message = create_user_message(content)

    # Get AI response
    ai_response = get_ai_response(content)

    # Create assistant message with extraction
    create_assistant_message(
      ai_response[:message],
      extracted_data: ai_response[:extracted_data]
    )

    # Create Answer records if data was extracted
    create_answers_from_extraction(ai_response[:extracted_data]) if ai_response[:extracted_data].present?

    ai_response
  end

  private

  def build_welcome_message
    <<~MSG
      Bonjour ! Je vais vous accompagner dans votre évaluation de conformité RGPD pour Monaco.

      Cette évaluation prendra environ 15-20 minutes. Je vais vous poser des questions sur votre organisation
      et vos pratiques de traitement des données personnelles.

      Vous pouvez me répondre naturellement - je comprendrai vos réponses et enregistrerai les informations
      nécessaires pour votre évaluation.

      Commençons par la première question : #{first_question_text}
    MSG
  end

  def first_question_text
    conversation.questionnaire.sections.first&.questions&.first&.question_text || "Êtes-vous prêt à commencer ?"
  end

  def create_user_message(content)
    conversation.messages.create!(
      role: :user,
      content: content
    )
  end

  def create_assistant_message(content, extracted_data: {})
    conversation.messages.create!(
      role: :assistant,
      content: content,
      extracted_data: extracted_data
    )
  end

  def get_ai_response(user_message)
    system_prompt = build_system_prompt
    conversation_history = build_conversation_history

    response = @client.messages.create(
      model: "claude-sonnet-4-20250514",
      max_tokens: 2048,
      system: system_prompt,
      messages: conversation_history + [{ role: "user", content: user_message }]
    )

    parse_ai_response(response)
  end

  def build_system_prompt
    <<~PROMPT
      You are a GDPR compliance assistant for Monaco (Loi n° 1.565). You help users complete their compliance assessment
      by conducting a natural conversation while extracting structured data.

      QUESTIONNAIRE STRUCTURE:
      #{questionnaire_structure_json}

      YOUR TASKS:
      1. Ask questions from the questionnaire naturally in French
      2. Understand user responses and extract structured data
      3. Clarify when responses are ambiguous
      4. Guide users through all required sections

      RESPONSE FORMAT:
      You MUST respond with ONLY raw JSON. Do NOT use markdown code fences. Do NOT wrap the JSON in ```.
      Your entire response should be parseable JSON starting with { and ending with }.

      JSON structure:
      {
        "message": "Your conversational response in French",
        "extracted_data": {
          "answers": [
            {"question_id": 123, "answer_type": "yes_no", "value": "Oui", "confidence": 0.95}
          ]
        },
        "next_action": "ask_next_question" | "clarify" | "complete"
      }

      CRITICAL: Return ONLY the JSON object. No markdown, no code fences, no additional text.

      Be professional, helpful, and clear. Use the intro_text and help_text from questions to provide context.
    PROMPT
  end

  def questionnaire_structure_json
    # Build simplified JSON structure of questionnaire
    conversation.questionnaire.as_json(
      include: {
        sections: {
          include: {
            questions: {
              only: [:id, :question_text, :question_type, :intro_text, :help_text, :order_index],
              include: {
                answer_choices: {
                  only: [:id, :choice_text]
                }
              }
            }
          }
        }
      }
    ).to_json
  end

  def build_conversation_history
    conversation.messages.chronological.map do |msg|
      {
        role: msg.role_user? ? "user" : "assistant",
        content: msg.content
      }
    end
  end

  def parse_ai_response(response)
    # Official SDK returns response object with content array
    content = response.content.first.text

    # Strip markdown code fences if present (```json ... ``` or ``` ... ```)
    content = content.strip
    content = content.gsub(/\A```(?:json)?\s*\n?/, "").gsub(/\n?```\z/, "")

    # Try to parse as JSON
    begin
      JSON.parse(content).deep_symbolize_keys
    rescue JSON::ParserError
      # Fallback if AI didn't return proper JSON
      {
        message: content,
        extracted_data: {},
        next_action: "ask_next_question"
      }
    end
  end

  def create_answers_from_extraction(extracted_data)
    return unless conversation.response.present?

    extracted_data[:answers]&.each do |answer_data|
      next unless answer_data[:confidence].to_f >= 0.7

      question = Question.find_by(id: answer_data[:question_id])
      next unless question

      create_answer_for_question(question, answer_data)
    end
  end

  def create_answer_for_question(question, answer_data)
    case question.question_type
    when "yes_no", "single_choice"
      choice = question.answer_choices.find_by(choice_text: answer_data[:value])
      conversation.response.answers.create!(
        question: question,
        answer_choice: choice
      ) if choice
    when "text_short", "text_long"
      conversation.response.answers.create!(
        question: question,
        answer_text: answer_data[:value]
      )
    end
  end
end
