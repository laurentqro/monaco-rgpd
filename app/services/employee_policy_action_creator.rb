class EmployeePolicyActionCreator
  EMPLOYEE_QUESTION_TEXT = "Avez-vous du personnel ?".freeze
  ACTION_TITLE = "Envoyer politique de confidentialité à vos salariés".freeze
  ACTION_DESCRIPTION = <<~DESC.squish
    Selon la Loi n° 1.565, vous devez informer vos salariés des données personnelles
    collectées, des finalités du traitement, et de la base légale. Veuillez distribuer
    la politique de confidentialité des salariés à l'ensemble de votre personnel.
  DESC

  def initialize(answer)
    @answer = answer
    @response = answer.response
    @account = @response.account
  end

  def call
    return unless should_create_action_item?
    return if action_item_already_exists?

    create_action_item!
  end

  private

  def should_create_action_item?
    return false unless @answer.question.question_text == EMPLOYEE_QUESTION_TEXT
    return false unless is_yes_answer?(@answer)
    true
  end

  def is_yes_answer?(answer)
    if answer.answer_choice.present?
      answer.answer_choice.choice_text == "Oui"
    elsif answer.answer_text.present?
      answer.answer_text == "Oui"
    else
      false
    end
  end

  def action_item_already_exists?
    ActionItem.exists?(
      account: @account,
      actionable: @response,
      source: :assessment,
      action_type: :generate_document
    )
  end

  def create_action_item!
    ActionItem.create!(
      account: @account,
      actionable: @response,
      source: :assessment,
      action_type: :generate_document,
      priority: :high,
      status: :pending,
      title: ACTION_TITLE,
      description: ACTION_DESCRIPTION
    )
  end
end
