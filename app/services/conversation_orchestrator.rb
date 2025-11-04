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

    # Create assistant message with extraction and suggested buttons
    assistant_data = ai_response[:extracted_data] || {}
    assistant_data[:suggested_buttons] = ai_response[:suggested_buttons] if ai_response[:suggested_buttons].present?

    create_assistant_message(
      ai_response[:message],
      extracted_data: assistant_data
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
        "suggested_buttons": {
          "question_id": 123,
          "buttons": [
            {"choice_id": 1, "label": "Oui"},
            {"choice_id": 2, "label": "Non"}
          ]
        },
        "extracted_data": {
          "answers": [
            {"question_id": 123, "answer_type": "yes_no", "value": "Oui", "confidence": 0.95}
          ]
        },
        "next_action": "ask_next_question" | "clarify" | "complete"
      }

      WHEN TO INCLUDE suggested_buttons:
      - Include when asking a yes_no question (show both Oui/Non buttons)
      - Include when asking a single_choice question (show all available choices as buttons)
      - Do NOT include for text_short or text_long questions (user should type freely)
      - Do NOT include during clarification or follow-up questions
      - Only suggest buttons from the actual answer_choices in the questionnaire structure

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
      parsed = JSON.parse(content).deep_symbolize_keys

      # Validate suggested_buttons if present
      if parsed[:suggested_buttons].present?
        validate_suggested_buttons(parsed[:suggested_buttons])
      end

      parsed
    rescue JSON::ParserError
      # Fallback if AI didn't return proper JSON
      {
        message: content,
        extracted_data: {},
        next_action: "ask_next_question"
      }
    end
  end

  def validate_suggested_buttons(suggested_buttons)
    # Ensure structure is valid
    unless suggested_buttons[:question_id].present? && suggested_buttons[:buttons].is_a?(Array)
      Rails.logger.warn("Invalid suggested_buttons format: #{suggested_buttons}")
      return false
    end

    # Ensure question exists
    question = Question.find_by(id: suggested_buttons[:question_id])
    unless question
      Rails.logger.warn("Suggested buttons for non-existent question: #{suggested_buttons[:question_id]}")
      return false
    end

    # Ensure all choice_ids are valid
    choice_ids = suggested_buttons[:buttons].map { |b| b[:choice_id] }.compact
    valid_choice_ids = question.answer_choices.pluck(:id)

    unless (choice_ids - valid_choice_ids).empty?
      Rails.logger.warn("Suggested buttons contain invalid choice_ids for question #{question.id}")
      return false
    end

    true
  end

  def create_answers_from_extraction(extracted_data)
    return unless conversation.response.present?

    extracted_data[:answers]&.each do |answer_data|
      next unless answer_data[:confidence].to_f >= 0.7

      question = Question.find_by(id: answer_data[:question_id])

      unless question
        Rails.logger.warn("Question not found: #{answer_data[:question_id]}")
        next
      end

      begin
        create_answer_for_question(question, answer_data)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Failed to create answer for question #{question.id}: #{e.message}")
        # Continue processing other answers
      end
    end
  end

  def create_answer_for_question(question, answer_data)
    # Find existing answer or create new one (can only have one answer per question)
    answer = conversation.response.answers.find_or_initialize_by(question: question)

    # Match existing answer_value format used in the codebase
    case question.question_type
    when "yes_no", "single_choice"
      choice = question.answer_choices.find_by(choice_text: answer_data[:value])
      return unless choice

      answer.answer_value = { choice_id: choice.id }
      answer.calculated_score = choice.score

    when "text_short", "text_long"
      answer.answer_value = { text: answer_data[:value] }
      answer.calculated_score = 50.0
    end

    answer.save!
  end
end
