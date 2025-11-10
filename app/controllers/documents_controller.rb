class DocumentsController < ApplicationController
  rescue_from PrivacyPolicyGenerator::AccountIncompleteError, with: :handle_incomplete_account
  rescue_from Grover::Error, with: :handle_pdf_generation_error

  before_action :set_account, only: [ :index, :show, :create ]

  def index
    # Get the latest completed response
    latest_response = Current.account.responses
      .completed
      .order(created_at: :desc)
      .first

    # Get documents from the latest response
    documents = latest_response ? latest_response.documents.ready.order(created_at: :desc) : []

    available_documents = available_documents_for_account

    render inertia: "Documents/Index", props: {
      documents: documents.map { |d| document_props(d) },
      latest_assessment: latest_response&.compliance_assessment ? {
        created_at: latest_response.created_at,
        overall_score: latest_response.compliance_assessment.overall_score.round(1)
      } : nil,
      available_documents: available_documents,
      account_complete: Current.account.complete_for_document_generation?,
      account: Current.account.as_json(only: [ :address, :phone, :rci_number, :legal_form ])
    }
  end

  def show
    @sections = [:hr_administration, :email_management, :telephony]
    render "documents/privacy_policy/show"
  end

  def create
    document_type = params[:document_type]

    # Currently only support privacy_policy_employees
    unless document_type == "privacy_policy_employees"
      return render json: { error: "unsupported_document_type" },
        status: :bad_request
    end

    unless @account.complete_for_document_generation?
      return render json: {
        error: "incomplete_profile",
        missing_fields: @account.missing_profile_fields
      }, status: :unprocessable_entity
    end

    response = @account.responses.completed.last

    unless response
      return render json: { error: "no_completed_questionnaire" },
        status: :unprocessable_entity
    end

    generator = PrivacyPolicyGenerator.new(@account, response)
    pdf_data = generator.generate

    send_data pdf_data,
      filename: "politique_confidentialite_#{@account.subdomain}_#{Date.current.iso8601}.pdf",
      type: "application/pdf",
      disposition: "attachment"
  end

  private

  def document_props(document)
    {
      id: document.id,
      title: document.title,
      document_type: document.document_type,
      status: document.status,
      generated_at: document.generated_at,
      download_url: document.pdf_file.attached? ? rails_blob_path(document.pdf_file, disposition: "attachment") : nil
    }
  end

  def available_documents_for_account
    docs = []

    # Check if account has completed questionnaire with employees
    if has_employees_response?
      docs << {
        type: "privacy_policy_employees",
        title: "Politique de confidentialité (salariés)",
        description: "Information des employés sur le traitement de leurs données personnelles",
        icon: "document-pdf"
      }
    end

    docs
  end

  def has_employees_response?
    @account.responses.completed.any? do |response|
      answer = response.answers
        .joins(:question)
        .find_by(questions: { question_text: "Avez-vous du personnel ?" })

      return false unless answer

      # Handle both hash format (production: {choice_id: X}) and string format (tests: "Oui")
      if answer.answer_choice.present?
        answer.answer_choice.choice_text == "Oui"
      elsif answer.answer_text.present?
        answer.answer_text == "Oui"
      else
        false
      end
    end
  end

  def handle_incomplete_account(error)
    render json: {
      error: "incomplete_profile",
      message: error.message,
      missing_fields: @account.missing_profile_fields
    }, status: :unprocessable_entity
  end

  def handle_pdf_generation_error(error)
    Rails.logger.error("PDF generation failed: #{error.message}")
    render json: {
      error: "generation_failed",
      message: "Une erreur est survenue lors de la génération du document"
    }, status: :internal_server_error
  end

  def set_account
    @account = Current.account
  end
end
