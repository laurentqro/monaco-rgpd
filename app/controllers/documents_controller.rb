class DocumentsController < ApplicationController
  def index
    documents = Current.account.documents
      .includes(:response)
      .order(generated_at: :desc)

    render inertia: 'Documents/Index', props: {
      documents: documents.map { |d| document_props(d) }
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
