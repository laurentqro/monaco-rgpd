class PrivacyPolicyGenerator
  class AccountIncompleteError < StandardError; end

  def initialize(account, response)
    @account = account
    @response = response
  end

  def generate
    validate_account_completeness!

    convert_to_pdf(render_html)
  end

  def sections_to_include
    sections = [:base]

    sections << :hr_administration if has_employees?
    sections << :email_management if has_professional_email?
    sections << :telephony if has_telephony?

    sections
  end

  private

  def validate_account_completeness!
    unless @account.complete_for_document_generation?
      missing = @account.missing_profile_fields.join(", ")
      raise AccountIncompleteError, "Missing required fields: #{missing}"
    end
  end

  def has_employees?
    is_yes_answer?(answer_for("Avez-vous du personnel ?"))
  end

  def has_professional_email?
    has_employees? && is_yes_answer?(answer_for("Vos employés disposent-ils d'une adresse email professionnelle ?"))
  end

  def has_telephony?
    has_employees? && is_yes_answer?(answer_for("Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?"))
  end

  def answer_for(question_text)
    answer = @response.answers
      .joins(:question)
      .find_by(questions: { question_text: question_text })
    answer&.answer_value
  end

  def is_yes_answer?(answer_value)
    return false unless answer_value

    # Handle both hash format (production: {choice_id: X}) and string format (tests: "Oui")
    if answer_value.is_a?(Hash)
      choice_id = answer_value["choice_id"] || answer_value[:choice_id]
      choice = AnswerChoice.find_by(id: choice_id)
      choice&.choice_text == "Oui"
    else
      answer_value == "Oui"
    end
  end

  def render_html
    ApplicationController.render(
      template: "documents/privacy_policy/show",
      layout: false,
      assigns: {
        account: @account,
        sections: sections_to_include
      }
    )
  end

  def convert_to_pdf(html)
    start_time = Time.current
    pdf = Grover.new(html, **pdf_options).to_pdf

    duration = (Time.current - start_time).round(2)
    Rails.logger.info("PDF generated successfully in #{duration}s")

    pdf
  rescue Grover::Error, Grover::JavaScript::Error => e
    duration = (Time.current - start_time).round(2)
    Rails.logger.error("PDF generation failed after #{duration}s: #{e.class} - #{e.message}")
    raise
  end

  def pdf_options
    {
      format: "A4",
      margin: {
        top: "2cm",
        bottom: "2cm",
        left: "2.5cm",
        right: "2.5cm"
      },
      display_header_footer: true,
      footer_template: footer_html,
      timeout: 60_000  # 60 seconds
    }
  end

  def footer_html
    # Single-line format for reliable Puppeteer rendering
    '<div style="font-size:9px;text-align:center;width:100%;color:#666;">' \
      '<span class="pageNumber"></span> / <span class="totalPages"></span>' \
      '</div>'
  end
end
