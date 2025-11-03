class PrivacyPolicyGenerator
  class AccountIncompleteError < StandardError; end

  def initialize(account, response)
    @account = account
    @response = response
  end

  def generate
    validate_account_completeness!

    html = render_template
    convert_to_pdf(html)
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
    answer_for("Avez-vous du personnel ?") == "Oui"
  end

  def has_professional_email?
    has_employees? && answer_for("Vos employés disposent-ils d'une adresse email professionnelle ?") == "Oui"
  end

  def has_telephony?
    has_employees? && answer_for("Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?") == "Oui"
  end

  def answer_for(question_text)
    answer = @response.answers
      .joins(:question)
      .find_by(questions: { question_text: question_text })
    answer&.answer_value
  end

  def render_template
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
    Grover.new(html, **pdf_options).to_pdf
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
    '<div style="font-size:9px; text-align:center; width:100%; color:#666;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>'
  end
end
