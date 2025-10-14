class QuestionnairesController < ApplicationController
  before_action :set_questionnaire, only: [:show]

  def show
    render inertia: "Questionnaires/Show", props: {
      questionnaire: questionnaire_props(@questionnaire)
    }
  end

  private

  def set_questionnaire
    @questionnaire = Questionnaire.published.find(params[:id])
  end

  def questionnaire_props(questionnaire)
    {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      sections: questionnaire.sections.map { |s| section_props(s) }
    }
  end

  def section_props(section)
    {
      id: section.id,
      title: section.title,
      description: section.description,
      order_index: section.order_index,
      questions: section.questions.map { |q| question_props(q) }
    }
  end

  def question_props(question)
    {
      id: question.id,
      question_text: question.question_text,
      question_type: question.question_type,
      help_text: question.help_text,
      is_required: question.is_required,
      weight: question.weight,
      answer_choices: question.answer_choices.map { |ac| answer_choice_props(ac) },
      logic_rules: question.logic_rules.map { |lr| logic_rule_props(lr) }
    }
  end

  def answer_choice_props(choice)
    {
      id: choice.id,
      choice_text: choice.choice_text,
      score: choice.score
    }
  end

  def logic_rule_props(rule)
    {
      id: rule.id,
      condition_type: rule.condition_type,
      condition_value: rule.condition_value,
      action: rule.action,
      target_section_id: rule.target_section_id,
      exit_message: rule.exit_message
    }
  end
end
