class DocumentsController < ApplicationController
  def index
    # Get the latest completed response
    latest_response = Current.account.responses
      .completed
      .order(created_at: :desc)
      .first

    # Get documents from the latest response
    documents = latest_response ? latest_response.documents.ready.order(created_at: :desc) : []

    render inertia: 'Documents/Index', props: {
      documents: documents.map { |d| document_props(d) },
      latest_assessment: latest_response&.compliance_assessment ? {
        created_at: latest_response.created_at,
        overall_score: latest_response.compliance_assessment.overall_score.round(1)
      } : nil
    }
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
end
