class DocumentGenerator
  DOCUMENT_TYPES = [ :privacy_policy, :processing_register, :consent_form, :employee_notice ]

  def initialize(response)
    @response = response
    @account = response.account
  end

  def generate_all
    DOCUMENT_TYPES.map do |doc_type|
      generate_document(doc_type)
    end
  end

  def generate_document(document_type)
    template = DocumentTemplate.active.find_by(document_type: document_type)
    return nil unless template

    document = @response.documents.create!(
      account: @account,
      document_type: document_type,
      title: "#{template.title} - #{@account.name}",
      status: :generating
    )

    begin
      # Render content from template
      context = build_context
      rendered_html = template.render(context)

      # Generate PDF
      pdf_content = PdfRenderer.new.render(rendered_html, document_type)

      # Attach PDF
      document.pdf_file.attach(
        io: StringIO.new(pdf_content),
        filename: "#{document.title.parameterize}.pdf",
        content_type: "application/pdf"
      )

      document.update!(
        status: :ready,
        generated_at: Time.current
      )

      document
    rescue => e
      # Use update instead of update! to avoid exception if transaction is already aborted
      document.update(status: :failed)
      raise e
    end
  end

  private

  def build_context
    {
      "account" => {
        "name" => @account.name,
        "entity_type" => @account.entity_type,
        "activity_sector" => @account.activity_sector,
        "employee_count" => @account.employee_count
      },
      "answers" => build_answers_context,
      "processing_activities" => build_processing_activities_context
    }
  end

  def build_answers_context
    # Build a hash of question codes to answers for easy template access
    @response.answers.includes(:question).each_with_object({}) do |answer, hash|
      question = answer.question
      # Use question ID or a custom code if available
      # Get the actual answer value from whichever field is populated
      hash["question_#{question.id}"] = answer.answer_choice&.choice_text || answer.answer_text || answer.answer_rating || answer.answer_number || answer.answer_date || answer.answer_boolean
    end
  end

  def build_processing_activities_context
    @account.processing_activities.includes(:processing_purposes, :data_category_details).map do |activity|
      {
        "name" => activity.name,
        "purposes" => activity.processing_purposes.map(&:purpose_name),
        "data_categories" => activity.data_category_details.map(&:detail),
        "retention_periods" => activity.data_category_details.map(&:retention_period)
      }
    end
  end
end
