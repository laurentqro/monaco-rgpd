require "test_helper"

class GenerateDocumentsJobTest < ActiveJob::TestCase
  test "should enqueue job with response id" do
    response = responses(:completed_response)

    assert_enqueued_with(job: GenerateDocumentsJob, args: [ response.id ]) do
      GenerateDocumentsJob.perform_later(response.id)
    end
  end

  test "should generate all document types for response" do
    response = responses(:completed_response)

    assert_difference "Document.count", 4 do
      GenerateDocumentsJob.perform_now(response.id)
    end

    # Check that all 4 document types are generated
    assert response.documents.document_type_privacy_policy.exists?
    assert response.documents.document_type_processing_register.exists?
    assert response.documents.document_type_consent_form.exists?
    assert response.documents.document_type_employee_notice.exists?
  end

  test "should attach PDF files to generated documents" do
    response = responses(:completed_response)

    GenerateDocumentsJob.perform_now(response.id)

    response.documents.each do |document|
      assert document.pdf_file.attached?, "PDF should be attached to #{document.document_type}"
      assert_equal "application/pdf", document.pdf_file.content_type
    end
  end

  test "should set document status to ready after successful generation" do
    response = responses(:completed_response)

    GenerateDocumentsJob.perform_now(response.id)

    response.documents.each do |document|
      assert document.status_ready?, "Document #{document.document_type} should be ready"
      assert document.generated_at.present?, "Document should have generated_at timestamp"
    end
  end

  test "should set document status to failed on error" do
    response = responses(:completed_response)

    # Simulate an error by making the template content invalid
    DocumentTemplate.update_all(content: "{{ invalid liquid tag")

    # The job should raise an error but mark the document as failed
    begin
      GenerateDocumentsJob.perform_now(response.id)
    rescue => e
      # Expected to raise an error
    end

    # At least one document should exist and be marked as failed
    failed_docs = response.documents.status_failed
    assert failed_docs.exists?, "Should have at least one failed document"
  end

  test "should use Liquid templates to render content with context" do
    response = responses(:completed_response)
    account = response.account

    GenerateDocumentsJob.perform_now(response.id)

    privacy_policy = response.documents.document_type_privacy_policy.first
    assert privacy_policy.present?
    assert privacy_policy.title.include?(account.name), "Title should include account name"
  end
end
