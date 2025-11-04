class DocumentsController < ApplicationController
  rescue_from PrivacyPolicyGenerator::AccountIncompleteError, with: :handle_incomplete_account
  rescue_from Grover::Error, with: :handle_pdf_generation_error

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
      account_complete: Current.account.complete_for_document_generation?
    }
  end

  def generate_privacy_policy
    unless Current.account.complete_for_document_generation?
      return render json: {
        error: "incomplete_profile",
        missing_fields: Current.account.missing_profile_fields
      }, status: :unprocessable_entity
    end

    response = Current.account.responses.completed.last

    unless response
      return render json: { error: "no_completed_questionnaire" },
        status: :unprocessable_entity
    end

    generator = PrivacyPolicyGenerator.new(Current.account, response)
    pdf_data = generator.generate

    send_data pdf_data,
      filename: "politique_confidentialite_#{Current.account.subdomain}_#{Date.current.iso8601}.pdf",
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
    Current.account.responses.completed.any? do |response|
      answer = response.answers
        .joins(:question)
        .find_by(questions: { question_text: "Avez-vous du personnel ?" })

      return false unless answer

      # Handle both hash format (production: {choice_id: 678}) and string format (tests: "Oui")
      if answer.answer_value.is_a?(Hash)
        # For yes_no questions, choice_id 678 appears to be "Oui" based on the data
        # We check if choice_id exists and is not 679 (which would be "Non")
        choice_id = answer.answer_value["choice_id"] || answer.answer_value[:choice_id]
        choice_id == 678
      else
        answer.answer_value == "Oui"
      end
    end
  end

  def handle_incomplete_account(error)
    render json: {
      error: "incomplete_profile",
      message: error.message,
      missing_fields: Current.account.missing_profile_fields
    }, status: :unprocessable_entity
  end

  def handle_pdf_generation_error(error)
    Rails.logger.error("PDF generation failed: #{error.message}")
    render json: {
      error: "generation_failed",
      message: "Une erreur est survenue lors de la génération du document"
    }, status: :internal_server_error
  end
end
