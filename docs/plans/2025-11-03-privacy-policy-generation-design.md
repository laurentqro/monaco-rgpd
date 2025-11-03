# Privacy Policy Document Generation - Design Document

**Date**: 2025-11-03
**Status**: Approved
**Author**: Design session with Laurent

## Overview

Generate downloadable PDF privacy policies (politique de confidentialité pour salariés) based on user account information and questionnaire responses. Documents are generated on-demand when users complete questionnaires indicating they have employees.

## User Flow

1. User completes questionnaire, indicates they have employees
2. "Documents" page shows available document type (PDF icon)
3. User clicks PDF icon to generate
4. System checks if account profile is complete (address, phone, RCI number, legal form)
5. If incomplete: Modal appears to collect missing information
6. If complete: PDF generates immediately
7. Browser downloads PDF: `politique_confidentialite_{subdomain}_{date}.pdf`

## Architecture Decision

**HTML/ERB → PDF (via Grover)** - chosen over DOCX templating

**Rationale:**
- Templates maintained by developers (not external legal team)
- HTML/ERB uses familiar Rails patterns
- Better for complex layouts with tables
- Cleaner version control (HTML diffs vs binary DOCX)
- Grover (headless Chrome) produces professional legal PDFs
- Simpler stack: one conversion step instead of two

**Alternatives considered:**
- Sablon/DOCX templating: Rejected because adds unnecessary complexity when developers maintain templates
- Prawn programmatic PDF: Rejected because complex table layouts are harder than HTML

## Data Model Changes

### Account Model Additions

New fields for document placeholders:

```ruby
add_column :accounts, :address, :text           # Multi-line company address
add_column :accounts, :phone, :string           # Contact phone
add_column :accounts, :rci_number, :string      # Répertoire du Commerce et de l'Industrie
add_column :accounts, :legal_form, :integer, default: 0  # Monaco legal entity type
```

### Legal Form Enum

Monaco-specific business entity types:

```ruby
enum :legal_form, {
  sarl: 0,   # Société à Responsabilité Limitée
  sam: 1,    # Société Anonyme Monégasque
  snc: 2,    # Société en Nom Collectif
  scs: 3,    # Société en Commandite Simple
  sca: 4,    # Société en Commandite par Actions
  surl: 5,   # Société Unipersonnelle à Responsabilité Limitée
  sima: 6,   # Société d'Innovation Monégasque par Actions
  ei: 7,     # Entreprise Individuelle
  sci: 8     # Société Civile Immobilière
}, prefix: :legal_form
```

### Account Methods

```ruby
def complete_for_document_generation?
  name.present? &&
  address.present? &&
  phone.present? &&
  rci_number.present? &&
  legal_form.present?
end

def legal_form_full_name
  # Returns full French name: "Société à Responsabilité Limitée (SARL)"
end

def missing_profile_fields
  # Returns array of missing field names for error messages
end
```

### Validation Strategy

- Fields remain optional on Account (allow saving incomplete accounts)
- Validated only when generating documents (explicit context)
- `complete_for_document_generation?` gates document generation

## Conditional Section Logic

### Service Object: PrivacyPolicyGenerator

Determines which document sections to include based on questionnaire responses.

**Always included sections:**
- Header (company info, document title)
- Article I: Identité du responsable du traitement
- Article III: Droits des personnes (mandatory under Loi n° 1.565)

**Conditional sections** (based on questionnaire):
- Section A - HR Administration: if has employees
- Section B - Email Management: if employees have professional email
- Section C - Telephony: if employees have phone lines
- Video Surveillance: if has video surveillance system
- Access Control: if has access control system

### Question Matching Strategy

Questions identified by full text match:
- `"Avez-vous du personnel ?"` → determines HR section
- `"Vos employés disposent-ils d'une adresse email professionnelle ?"` → email section
- `"Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?"` → telephony section

**Rationale**: Text matching is self-documenting and simpler for MVP than adding `key` fields to questions.

### Service Object Structure

```ruby
class PrivacyPolicyGenerator
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
    # ... etc
    sections
  end

  private

  def has_employees?
    answer_for("Avez-vous du personnel ?") == "Oui"
  end

  def answer_for(question_text)
    @response.answers
      .joins(:question)
      .find_by(questions: { question_text: question_text })
      &.answer_value
  end
end
```

## Template Structure

### Directory Layout

```
app/views/documents/privacy_policy/
├── show.html.erb                      # Main orchestrator template
├── privacy_policy.css                 # Professional legal document styling
└── sections/
    ├── _header.html.erb               # Company info, title
    ├── _controller_identity.html.erb  # Article I
    ├── _processing_overview.html.erb  # Article II intro
    ├── _hr_administration.html.erb    # Section A (conditional)
    ├── _email_management.html.erb     # Section B (conditional)
    ├── _telephony.html.erb            # Section C (conditional)
    ├── _video_surveillance.html.erb   # Conditional
    ├── _data_security.html.erb        # Security measures
    └── _data_subject_rights.html.erb  # Article III (always)
```

### Main Template Pattern

```erb
<!DOCTYPE html>
<html>
<head>
  <%= stylesheet_link_tag 'documents/privacy_policy', media: 'all' %>
</head>
<body>
  <%= render 'sections/header', account: @account %>
  <%= render 'sections/controller_identity', account: @account %>
  <%= render 'sections/processing_overview' %>

  <% if @sections.include?(:hr_administration) %>
    <%= render 'sections/hr_administration', account: @account %>
  <% end %>

  <% if @sections.include?(:email_management) %>
    <%= render 'sections/email_management', account: @account %>
  <% end %>

  <%= render 'sections/data_subject_rights', account: @account %>
</body>
</html>
```

### CSS Approach

Professional legal document styling:
- Serif fonts (Times New Roman or similar)
- Proper spacing and margins (2cm-2.5cm)
- Page break controls for sections
- Table styling for data processing matrices
- Footer with page numbers

## Routes & Controller

### Routes

```ruby
# Option 1: RESTful namespace
namespace :documents do
  resource :privacy_policy, only: [:create]
end

# Option 2: Collection action
resources :documents, only: [:index] do
  collection do
    post :generate_privacy_policy
  end
end
```

### Controller

```ruby
class DocumentsController < ApplicationController
  rescue_from AccountIncompleteError, with: :handle_incomplete_account
  rescue_from Grover::Error, with: :handle_pdf_generation_error

  def index
    @available_documents = available_documents_for_account

    render inertia: 'Documents/Index',
      props: {
        available_documents: @available_documents,
        account_complete: current_account.complete_for_document_generation?
      }
  end

  def generate_privacy_policy
    unless current_account.complete_for_document_generation?
      return render json: {
        error: 'incomplete_profile',
        missing_fields: current_account.missing_profile_fields
      }, status: :unprocessable_entity
    end

    response = current_account.responses.completed.last

    unless response
      return render json: { error: 'no_completed_questionnaire' },
        status: :unprocessable_entity
    end

    generator = PrivacyPolicyGenerator.new(current_account, response)
    pdf_data = generator.generate

    send_data pdf_data,
      filename: "politique_confidentialite_#{current_account.subdomain}_#{Date.current.iso8601}.pdf",
      type: 'application/pdf',
      disposition: 'attachment'
  end

  private

  def available_documents_for_account
    docs = []

    if current_account.responses.completed.any? { |r| r.has_employees? }
      docs << {
        type: 'privacy_policy_employees',
        title: 'Politique de confidentialité (salariés)',
        description: 'Information des employés sur le traitement de leurs données personnelles',
        icon: 'document-pdf'
      }
    end

    docs
  end

  def handle_incomplete_account(error)
    render json: {
      error: 'incomplete_profile',
      message: error.message,
      missing_fields: current_account.missing_profile_fields
    }, status: :unprocessable_entity
  end

  def handle_pdf_generation_error(error)
    Rails.logger.error("PDF generation failed: #{error.message}")
    render json: {
      error: 'generation_failed',
      message: "Une erreur est survenue lors de la génération du document"
    }, status: :internal_server_error
  end
end
```

## Frontend (Svelte/Inertia)

### Documents Index Page

```svelte
<!-- app/frontend/pages/Documents/Index.svelte -->
<script>
  import { router } from '@inertiajs/svelte'
  import ProfileCompletionModal from './ProfileCompletionModal.svelte'

  export let available_documents = []
  export let account_complete = false

  let showProfileModal = false
  let pendingDocumentType = null

  function handleGenerateDocument(docType) {
    if (!account_complete) {
      pendingDocumentType = docType
      showProfileModal = true
      return
    }

    generateDocument(docType)
  }

  function generateDocument(docType) {
    router.post(`/documents/${docType}`, {}, {
      onError: (errors) => {
        if (errors.error === 'incomplete_profile') {
          showProfileModal = true
        }
      }
    })
  }

  function onProfileCompleted() {
    showProfileModal = false
    account_complete = true
    if (pendingDocumentType) {
      generateDocument(pendingDocumentType)
      pendingDocumentType = null
    }
  }
</script>

<div class="documents-page">
  <h1>Documents</h1>

  {#if available_documents.length === 0}
    <p>Complétez le questionnaire pour générer vos documents de conformité.</p>
  {:else}
    <div class="documents-grid">
      {#each available_documents as doc}
        <button
          class="document-card"
          on:click={() => handleGenerateDocument(doc.type)}
        >
          <icon name={doc.icon} />
          <h3>{doc.title}</h3>
          <p>{doc.description}</p>
        </button>
      {/each}
    </div>
  {/if}
</div>

<ProfileCompletionModal
  open={showProfileModal}
  on:completed={onProfileCompleted}
  on:cancel={() => showProfileModal = false}
/>
```

### Profile Completion Modal

Form to collect missing account fields:
- Address (textarea)
- Phone (tel input)
- RCI Number (text input with format hint)
- Legal Form (select dropdown with full Monaco entity names)

On submit: PATCH `/account/complete_profile` → Updates account → Triggers document generation

## PDF Generation (Grover)

### Configuration

```ruby
# Gemfile
gem 'grover'

# config/initializers/grover.rb
Grover.configure do |config|
  config.options = {
    format: 'A4',
    margin: {
      top: '2cm',
      bottom: '2cm',
      left: '2.5cm',
      right: '2.5cm'
    },
    print_background: true,
    prefer_css_page_size: true,
    display_header_footer: true,
    footer_template: '<div style="font-size:9px; text-align:center; width:100%; color:#666;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>'
  }
end
```

### Generation Process

```ruby
def generate
  validate_account_completeness!

  html = ApplicationController.render(
    template: 'documents/privacy_policy/show',
    layout: false,
    assigns: {
      account: @account,
      sections: sections_to_include
    }
  )

  pdf = Grover.new(html, **pdf_options).to_pdf
  pdf
end
```

## Testing Strategy

### Unit Tests

```ruby
# test/services/privacy_policy_generator_test.rb
- Test section inclusion logic based on questionnaire answers
- Test account completeness validation
- Test PDF generation produces valid output
- Test question text matching
```

### System Tests

```ruby
# test/system/documents_generation_test.rb
- Test complete flow: visit documents page → click icon → download PDF
- Test profile completion modal when account incomplete
- Test error handling for missing questionnaire
```

### Test Coverage

- Account validation: complete vs incomplete profiles
- Conditional sections: all combinations of questionnaire answers
- Error handling: missing questionnaire, PDF generation failures
- Edge cases: no answers, malformed data

## Error Handling

### Custom Exceptions

```ruby
class AccountIncompleteError < StandardError; end
```

### Controller Error Handlers

- `AccountIncompleteError`: Return 422 with missing fields
- `Grover::Error`: Log error, return 500 with user-friendly message
- Missing questionnaire: Return 422 with specific error code

### Edge Cases Handled

- Account profile incomplete
- No completed questionnaire exists
- Grover/Puppeteer fails to generate PDF
- Missing answers for expected questions
- Network timeouts during PDF generation

## Out of Scope (MVP)

**Not included in initial release:**
- Document versioning/audit trail
- Storing generated documents in database
- Multiple template versions per document type
- Batch document generation
- Email delivery of documents
- Document regeneration notifications when account changes
- Admin preview of templates

**Future considerations:**
- External privacy policy (for customers/website visitors)
- Data Processing Agreements (DPA)
- Data Protection Impact Assessments (DPIA)
- Cookie policies
- Template customization per account

## Dependencies

### New Gems

```ruby
gem 'grover'  # HTML to PDF via headless Chrome/Puppeteer
```

### System Requirements

- Node.js (for Puppeteer)
- Chrome/Chromium (installed by Puppeteer)

### Configuration Files

- `config/initializers/grover.rb`
- CSS stylesheet for PDF styling

## Migration Path

### Phase 1: Core Implementation
1. Add Account fields (address, phone, rci_number, legal_form)
2. Create PrivacyPolicyGenerator service
3. Build ERB templates from DOCX source
4. Implement Documents controller and routes
5. Build Svelte frontend pages

### Phase 2: Testing & Refinement
1. Write comprehensive tests
2. Test with real user data
3. Refine PDF styling
4. Performance testing (PDF generation speed)

### Phase 3: Future Enhancements
1. Additional document types
2. Template versioning
3. Document storage/audit trail

## Success Metrics

- Users with employees can generate privacy policy PDF
- PDF includes correct conditional sections based on questionnaire
- PDF meets professional legal document standards
- Generation completes in < 5 seconds
- No manual document creation needed

## Technical Risks

### Risk: Grover/Puppeteer installation complexity
**Mitigation**: Document clear setup steps, use Docker for consistent environment

### Risk: PDF styling doesn't match legal requirements
**Mitigation**: Early validation with sample documents, iterate on CSS

### Risk: Template maintenance becomes complex
**Mitigation**: Use partials heavily, keep sections independent, document template structure

### Risk: Question text changes break condition matching
**Mitigation**: Add tests that fail if question text changes, consider adding `key` field in future

## Decision Log

| Decision | Rationale | Date |
|----------|-----------|------|
| HTML/ERB over DOCX templates | Developers maintain templates, better tooling | 2025-11-03 |
| Grover over Prawn | Better for complex table layouts | 2025-11-03 |
| Lazy profile completion | Reduce onboarding friction | 2025-11-03 |
| Generate on-demand (no storage) | Simpler MVP, unclear if versioning needed | 2025-11-03 |
| Question text matching | Simpler than key field for MVP | 2025-11-03 |
| Monaco-specific legal forms enum | Accurate compliance with Monaco law | 2025-11-03 |
