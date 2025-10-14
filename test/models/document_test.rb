require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should create document for response" do
    account = accounts(:basic)
    response = responses(:one)

    document = Document.create!(
      account: account,
      response: response,
      document_type: :privacy_policy,
      title: "Politique de confidentialité - Test",
      status: :generating
    )

    assert_equal "privacy_policy", document.document_type
    assert_equal "generating", document.status
  end

  test "document template should have versions" do
    template = DocumentTemplate.create!(
      document_type: :privacy_policy,
      title: "Privacy Policy Template",
      content: "{{ account.name }}",
      version: 1,
      is_active: true
    )

    assert_equal 1, template.version
    assert template.is_active?
  end

  test "document template should render with Liquid" do
    template = DocumentTemplate.create!(
      document_type: :privacy_policy,
      title: "Privacy Policy Template",
      content: "Company: {{ company_name }}",
      version: 1,
      is_active: true
    )

    rendered = template.render({ "company_name" => "Test Company" })
    assert_equal "Company: Test Company", rendered
  end

  test "document template should create version snapshot on update" do
    template = DocumentTemplate.create!(
      document_type: :privacy_policy,
      title: "Privacy Policy Template",
      content: "Original content",
      version: 1,
      is_active: true
    )

    assert_equal 0, template.document_template_versions.count

    template.update!(content: "Updated content")

    assert_equal 1, template.document_template_versions.count
    assert_equal 2, template.version
    assert_equal "Original content", template.document_template_versions.first.content
    assert_equal 1, template.document_template_versions.first.version
  end

  test "document should belong to account and response" do
    account = accounts(:basic)
    response = responses(:one)

    document = Document.create!(
      account: account,
      response: response,
      document_type: :privacy_policy,
      title: "Test Document",
      status: :generating
    )

    assert_equal account, document.account
    assert_equal response, document.response
  end

  test "document template version should belong to template" do
    template = DocumentTemplate.create!(
      document_type: :privacy_policy,
      title: "Privacy Policy Template",
      content: "Original content",
      version: 1,
      is_active: true
    )

    version = template.document_template_versions.create!(
      content: "Version content",
      version: 1
    )

    assert_equal template, version.document_template
  end

  test "document should have enum for document_type" do
    document = Document.new(
      account: accounts(:basic),
      response: responses(:one),
      document_type: :privacy_policy,
      title: "Test",
      status: :generating
    )

    assert document.document_type_privacy_policy?
    document.document_type = :processing_register
    assert document.document_type_processing_register?
  end

  test "document should have enum for status" do
    document = Document.new(
      account: accounts(:basic),
      response: responses(:one),
      document_type: :privacy_policy,
      title: "Test",
      status: :generating
    )

    assert document.status_generating?
    document.status = :ready
    assert document.status_ready?
  end

  test "document template should have enum for document_type" do
    template = DocumentTemplate.new(
      document_type: :privacy_policy,
      title: "Test",
      content: "Test content",
      version: 1
    )

    assert template.document_type_privacy_policy?
    template.document_type = :consent_form
    assert template.document_type_consent_form?
  end

  test "document should validate presence of required fields" do
    document = Document.new
    assert_not document.valid?
    assert_includes document.errors[:title], "doit être rempli"
    assert_includes document.errors[:document_type], "doit être rempli"
    # Note: status has a default value so it won't fail presence validation
  end

  test "document template should validate presence of required fields" do
    template = DocumentTemplate.new
    assert_not template.valid?
    assert_includes template.errors[:title], "doit être rempli"
    assert_includes template.errors[:content], "doit être rempli"
    assert_includes template.errors[:document_type], "doit être rempli"
  end

  test "document template version should validate presence of required fields" do
    version = DocumentTemplateVersion.new
    assert_not version.valid?
    assert_includes version.errors[:content], "doit être rempli"
    assert_includes version.errors[:version], "doit être rempli"
  end
end
