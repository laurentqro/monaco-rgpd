# frozen_string_literal: true

# ProcessingActivityGenerator
# Generates ProcessingActivity records from templates based on questionnaire responses
class ProcessingActivityGenerator
  def initialize(response)
    @response = response
    @account = response.account
    @created_activities = []
  end

  def generate_from_questionnaire
    ProcessingActivityTemplates::QUESTION_TEMPLATE_MAP.each do |question_text, template_method|
      create_if_answered_yes(question_text, template_method)
    end

    @created_activities
  end

  private

  def create_if_answered_yes(question_text, template_method)
    question = find_question(question_text)
    return unless question

    answer = find_answer(question)
    return unless answer

    yes_choice = find_yes_choice(question)
    return unless yes_choice
    return unless answer.answer_choice_id == yes_choice.id

    # Check if activity already exists for this response and template
    template_name = ProcessingActivityTemplates.public_send(template_method)[:name]
    return if activity_exists?(template_name)

    create_activity(template_method)
  end

  def find_question(question_text)
    @response.questionnaire.questions.find_by(question_text: question_text)
  end

  def find_answer(question)
    @response.answers.find_by(question: question)
  end

  def find_yes_choice(question)
    question.answer_choices.find_by(choice_text: "Oui")
  end

  def activity_exists?(name)
    @account.processing_activities.exists?(
      response_id: @response.id,
      name: name
    )
  end

  def create_activity(template_method)
    template = ProcessingActivityTemplates.public_send(template_method)

    activity = @account.processing_activities.create!(
      template.merge(response_id: @response.id)
    )

    @created_activities << activity
    activity
  end
end
