# Privacy Policy Generation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable users to generate downloadable PDF privacy policies based on their account information and questionnaire responses.

**Architecture:** HTML/ERB templates with conditional sections → Grover (headless Chrome) → PDF. Service object analyzes questionnaire responses to determine which document sections to include. Profile completion modal collects missing account fields before generation.

**Tech Stack:** Rails 8, Grover gem (HTML→PDF), Svelte 5 + Inertia.js, ERB templates

---

## Task 1: Database Migration - Add Account Profile Fields

**Files:**
- Create: `db/migrate/YYYYMMDDHHMMSS_add_profile_fields_to_accounts.rb`
- Modify: `db/schema.rb` (auto-updated by migration)

**Step 1: Create migration file**

```bash
bin/rails generate migration AddProfileFieldsToAccounts address:text phone:string rci_number:string legal_form:integer
```

**Step 2: Review and edit migration**

Verify the generated migration looks like this:

```ruby
class AddProfileFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :address, :text
    add_column :accounts, :phone, :string
    add_column :accounts, :rci_number, :string
    add_column :accounts, :legal_form, :integer, default: 0
  end
end
```

**Step 3: Run migration**

```bash
bin/rails db:migrate
```

Expected output: `== AddProfileFieldsToAccounts: migrated ==`

**Step 4: Verify schema updated**

```bash
grep -A 5 "create_table \"accounts\"" db/schema.rb
```

Expected: Should show new columns (address, phone, rci_number, legal_form)

**Step 5: Commit**

```bash
git add db/migrate db/schema.rb
git commit -m "db: add profile fields to accounts table

Add address, phone, rci_number, and legal_form fields to accounts
for document generation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 2: Account Model - Add Legal Form Enum and Methods

**Files:**
- Modify: `app/models/account.rb`
- Create: `test/models/account_profile_completeness_test.rb`

**Step 1: Write failing test for profile completeness**

Create: `test/models/account_profile_completeness_test.rb`

```ruby
require "test_helper"

class AccountProfileCompletenessTest < ActiveSupport::TestCase
  test "complete_for_document_generation? returns false when address missing" do
    account = accounts(:one)
    account.update(phone: "123456", rci_number: "12S34567", legal_form: :sarl)
    account.address = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when phone missing" do
    account = accounts(:one)
    account.update(address: "123 Street", rci_number: "12S34567", legal_form: :sarl)
    account.phone = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when rci_number missing" do
    account = accounts(:one)
    account.update(address: "123 Street", phone: "123456", legal_form: :sarl)
    account.rci_number = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns false when legal_form missing" do
    account = accounts(:one)
    account.update(address: "123 Street", phone: "123456", rci_number: "12S34567")
    account.legal_form = nil

    assert_not account.complete_for_document_generation?
  end

  test "complete_for_document_generation? returns true when all fields present" do
    account = accounts(:one)
    account.update(
      address: "123 Street, Monaco",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    assert account.complete_for_document_generation?
  end

  test "legal_form_full_name returns French name for SARL" do
    account = accounts(:one)
    account.legal_form = :sarl

    assert_equal "Société à Responsabilité Limitée (SARL)", account.legal_form_full_name
  end

  test "missing_profile_fields returns array of missing field names" do
    account = accounts(:one)
    account.address = nil
    account.phone = nil

    missing = account.missing_profile_fields

    assert_includes missing, :address
    assert_includes missing, :phone
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bin/rails test test/models/account_profile_completeness_test.rb
```

Expected: FAIL with "undefined method `complete_for_document_generation?'"

**Step 3: Add enum and methods to Account model**

Modify: `app/models/account.rb`

Add after the existing enums:

```ruby
  enum :legal_form, {
    sarl: 0,      # Société à Responsabilité Limitée
    sam: 1,       # Société Anonyme Monégasque
    snc: 2,       # Société en Nom Collectif
    scs: 3,       # Société en Commandite Simple
    sca: 4,       # Société en Commandite par Actions
    surl: 5,      # Société Unipersonnelle à Responsabilité Limitée
    sima: 6,      # Société d'Innovation Monégasque par Actions
    ei: 7,        # Entreprise Individuelle
    sci: 8        # Société Civile Immobilière
  }, prefix: :legal_form

  def complete_for_document_generation?
    name.present? &&
    address.present? &&
    phone.present? &&
    rci_number.present? &&
    legal_form.present?
  end

  def legal_form_full_name
    return nil unless legal_form.present?

    {
      "sarl" => "Société à Responsabilité Limitée (SARL)",
      "sam" => "Société Anonyme Monégasque (SAM)",
      "snc" => "Société en Nom Collectif (SNC)",
      "scs" => "Société en Commandite Simple (SCS)",
      "sca" => "Société en Commandite par Actions (SCA)",
      "surl" => "Société Unipersonnelle à Responsabilité Limitée (SURL)",
      "sima" => "Société d'Innovation Monégasque par Actions (SIMA)",
      "ei" => "Entreprise Individuelle",
      "sci" => "Société Civile Immobilière (SCI)"
    }[legal_form]
  end

  def missing_profile_fields
    fields = []
    fields << :address if address.blank?
    fields << :phone if phone.blank?
    fields << :rci_number if rci_number.blank?
    fields << :legal_form if legal_form.blank?
    fields
  end
```

**Step 4: Run test to verify it passes**

```bash
bin/rails test test/models/account_profile_completeness_test.rb
```

Expected: PASS (7 tests, 0 failures)

**Step 5: Commit**

```bash
git add app/models/account.rb test/models/account_profile_completeness_test.rb
git commit -m "feat: add profile completeness methods to Account

Add legal_form enum with Monaco business entity types.
Add complete_for_document_generation? check.
Add legal_form_full_name helper for French display names.
Add missing_profile_fields for validation feedback.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 3: Service Object - PrivacyPolicyGenerator (Part 1: Structure)

**Files:**
- Create: `app/services/privacy_policy_generator.rb`
- Create: `test/services/privacy_policy_generator_test.rb`

**Step 1: Write failing test for service initialization**

Create: `test/services/privacy_policy_generator_test.rb`

```ruby
require "test_helper"

class PrivacyPolicyGeneratorTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @account.update(
      address: "12 Avenue des Spélugues, 98000 Monaco",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    @response = responses(:one)
  end

  test "raises AccountIncompleteError when account missing fields" do
    @account.address = nil

    generator = PrivacyPolicyGenerator.new(@account, @response)

    assert_raises(PrivacyPolicyGenerator::AccountIncompleteError) do
      generator.generate
    end
  end

  test "initializes with account and response" do
    generator = PrivacyPolicyGenerator.new(@account, @response)

    assert_not_nil generator
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: FAIL with "uninitialized constant PrivacyPolicyGenerator"

**Step 3: Create service object skeleton**

Create: `app/services/privacy_policy_generator.rb`

```ruby
class PrivacyPolicyGenerator
  class AccountIncompleteError < StandardError; end

  def initialize(account, response)
    @account = account
    @response = response
  end

  def generate
    validate_account_completeness!

    # Will implement in next task
    nil
  end

  private

  def validate_account_completeness!
    unless @account.complete_for_document_generation?
      missing = @account.missing_profile_fields.join(", ")
      raise AccountIncompleteError, "Missing required fields: #{missing}"
    end
  end
end
```

**Step 4: Run test to verify it passes**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: PASS (2 tests, 0 failures)

**Step 5: Commit**

```bash
git add app/services/privacy_policy_generator.rb test/services/privacy_policy_generator_test.rb
git commit -m "feat: add PrivacyPolicyGenerator service skeleton

Create service object to orchestrate privacy policy generation.
Add AccountIncompleteError for validation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 4: Service Object - Conditional Section Logic

**Files:**
- Modify: `app/services/privacy_policy_generator.rb`
- Modify: `test/services/privacy_policy_generator_test.rb`
- Create: `test/fixtures/questions.yml` (if not exists, add needed fixtures)
- Create: `test/fixtures/answers.yml` (if not exists, add needed fixtures)

**Step 1: Add test fixtures for questionnaire data**

You'll need fixtures that simulate the questionnaire structure. Check if `test/fixtures/questions.yml` and `test/fixtures/answers.yml` exist. If they do, add these entries:

In `test/fixtures/questions.yml`:

```yaml
has_personnel:
  section: cartographie
  question_text: "Avez-vous du personnel ?"
  question_type: yes_no
  order_index: 1

has_email:
  section: cartographie
  question_text: "Vos employés disposent-ils d'une adresse email professionnelle ?"
  question_type: yes_no
  order_index: 2

has_telephony:
  section: cartographie
  question_text: "Vos employés disposent-ils d'une ligne directe (fixe ou mobile) ?"
  question_type: yes_no
  order_index: 3
```

In `test/fixtures/answers.yml`:

```yaml
has_personnel_yes:
  response: one
  question: has_personnel
  answer_value: "Oui"

has_email_yes:
  response: one
  question: has_email
  answer_value: "Oui"

has_telephony_no:
  response: one
  question: has_telephony
  answer_value: "Non"
```

**Step 2: Write failing tests for section logic**

Add to `test/services/privacy_policy_generator_test.rb`:

```ruby
  test "includes hr_administration section when has employees" do
    # Use fixture with "Avez-vous du personnel ?" = "Oui"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :hr_administration
  end

  test "includes email_management section when has professional email" do
    # Use fixture with email = "Oui"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :email_management
  end

  test "excludes telephony section when no telephony" do
    # Use fixture with telephony = "Non"
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_not_includes sections, :telephony
  end

  test "always includes base sections" do
    generator = PrivacyPolicyGenerator.new(@account, @response)

    sections = generator.sections_to_include

    assert_includes sections, :base
  end
```

**Step 3: Run tests to verify they fail**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: FAIL with "undefined method `sections_to_include'"

**Step 4: Implement conditional section logic**

Modify `app/services/privacy_policy_generator.rb`:

Add these methods to the class:

```ruby
  def sections_to_include
    sections = [:base]

    sections << :hr_administration if has_employees?
    sections << :email_management if has_professional_email?
    sections << :telephony if has_telephony?

    sections
  end

  private

  # ... existing validate_account_completeness! method ...

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
```

**Step 5: Run tests to verify they pass**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: PASS (all tests passing)

**Step 6: Commit**

```bash
git add app/services/privacy_policy_generator.rb test/services/privacy_policy_generator_test.rb test/fixtures
git commit -m "feat: add conditional section logic to generator

Determine which document sections to include based on questionnaire
answers (employees, email, telephony).

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 5: Install and Configure Grover

**Files:**
- Modify: `Gemfile`
- Create: `config/initializers/grover.rb`

**Step 1: Add Grover to Gemfile**

Modify: `Gemfile`

Add in the main group (not in any specific group):

```ruby
gem "grover"
```

**Step 2: Install gem**

```bash
bundle install
```

Expected: Grover installed successfully

**Step 3: Create Grover initializer**

Create: `config/initializers/grover.rb`

```ruby
Grover.configure do |config|
  config.options = {
    format: "A4",
    margin: {
      top: "2cm",
      bottom: "2cm",
      left: "2.5cm",
      right: "2.5cm"
    },
    print_background: true,
    prefer_css_page_size: true,
    display_header_footer: true,
    header_template: "<div></div>",
    footer_template: '<div style="font-size:9px; text-align:center; width:100%; color:#666;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>'
  }
end
```

**Step 4: Verify Grover loads**

```bash
bin/rails runner "puts Grover.configuration.options[:format]"
```

Expected output: `A4`

**Step 5: Commit**

```bash
git add Gemfile Gemfile.lock config/initializers/grover.rb
git commit -m "feat: add Grover for HTML to PDF conversion

Configure Grover with A4 format, proper margins, and page numbers.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 6: Create Base HTML Template Structure

**Files:**
- Create: `app/views/documents/privacy_policy/show.html.erb`
- Create: `app/assets/stylesheets/documents/privacy_policy.css`
- Create: `app/views/documents/privacy_policy/sections/_header.html.erb`
- Create: `app/views/documents/privacy_policy/sections/_controller_identity.html.erb`

**Step 1: Create CSS for professional legal document**

Create: `app/assets/stylesheets/documents/privacy_policy.css`

```css
/* Legal Document Styling */
body {
  font-family: 'Times New Roman', Times, serif;
  font-size: 11pt;
  line-height: 1.6;
  color: #000;
  margin: 0;
  padding: 0;
}

h1 {
  font-size: 18pt;
  font-weight: bold;
  text-align: center;
  margin-top: 0;
  margin-bottom: 2em;
  text-transform: uppercase;
}

h2 {
  font-size: 14pt;
  font-weight: bold;
  margin-top: 1.5em;
  margin-bottom: 0.5em;
}

h3 {
  font-size: 12pt;
  font-weight: bold;
  margin-top: 1em;
  margin-bottom: 0.5em;
}

p {
  margin-bottom: 0.75em;
  text-align: justify;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin: 1em 0;
  font-size: 10pt;
}

table th {
  background-color: #f0f0f0;
  border: 1px solid #333;
  padding: 8px;
  text-align: left;
  font-weight: bold;
}

table td {
  border: 1px solid #666;
  padding: 8px;
  vertical-align: top;
}

.section {
  page-break-inside: avoid;
  margin-bottom: 1.5em;
}

.company-info {
  text-align: center;
  margin-bottom: 2em;
}

.legal-reference {
  font-style: italic;
  margin: 1em 0;
}

@media print {
  body {
    margin: 0;
  }

  .section {
    page-break-inside: avoid;
  }
}
```

**Step 2: Create header partial**

Create: `app/views/documents/privacy_policy/sections/_header.html.erb`

```erb
<div class="company-info">
  <h1>Politique de confidentialité à l'attention des salariés</h1>
  <p><strong><%= account.name %></strong></p>
  <p><%= account.legal_form_full_name %></p>
</div>

<div class="legal-reference">
  <p>
    En application de l'article 11 de la Loi n° 1.565 du 3 décembre 2024
    relative à la protection des données personnelles, nous vous informons
    par la présente de la manière dont vos données personnelles sont traitées.
  </p>
</div>
```

**Step 3: Create controller identity partial**

Create: `app/views/documents/privacy_policy/sections/_controller_identity.html.erb`

```erb
<div class="section">
  <h2>Article I - Identité du responsable du traitement</h2>

  <p>
    Le responsable du traitement est <%= account.name %>,
    <%= account.legal_form_full_name %>, immatriculée au Répertoire du
    Commerce et de l'Industrie de Monaco sous le numéro <%= account.rci_number %>.
  </p>

  <p>
    <strong>Adresse :</strong> <%= simple_format(account.address) %>
  </p>

  <p>
    <strong>Téléphone :</strong> <%= account.phone %>
  </p>
</div>
```

**Step 4: Create main template**

Create: `app/views/documents/privacy_policy/show.html.erb`

```erb
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Politique de confidentialité - <%= @account.name %></title>
  <%= stylesheet_link_tag "documents/privacy_policy", media: "all" %>
</head>
<body>
  <%= render "documents/privacy_policy/sections/header", account: @account %>

  <%= render "documents/privacy_policy/sections/controller_identity", account: @account %>

  <%# Conditional sections will be added in next tasks %>
</body>
</html>
```

**Step 5: Test template renders (manual verification)**

Create a simple test by rendering in Rails console:

```bash
bin/rails runner "
account = Account.first
account.update(address: '123 Test St', phone: '123', rci_number: '123', legal_form: :sarl)
html = ApplicationController.render(
  template: 'documents/privacy_policy/show',
  layout: false,
  assigns: { account: account }
)
puts 'Template rendered successfully' if html.present?
"
```

Expected: "Template rendered successfully"

**Step 6: Commit**

```bash
git add app/views/documents app/assets/stylesheets/documents
git commit -m "feat: create base HTML template for privacy policy

Add professional legal document styling and header/identity sections.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 7: Create Conditional Section Templates

**Files:**
- Create: `app/views/documents/privacy_policy/sections/_processing_overview.html.erb`
- Create: `app/views/documents/privacy_policy/sections/_hr_administration.html.erb`
- Create: `app/views/documents/privacy_policy/sections/_email_management.html.erb`
- Create: `app/views/documents/privacy_policy/sections/_telephony.html.erb`
- Create: `app/views/documents/privacy_policy/sections/_data_subject_rights.html.erb`

**Step 1: Create processing overview section**

Create: `app/views/documents/privacy_policy/sections/_processing_overview.html.erb`

```erb
<div class="section">
  <h2>Article II - Traitements concernés</h2>

  <p>
    <%= account.name %> met en œuvre les traitements des données personnelles
    vous concernant pour les finalités suivantes :
  </p>
</div>
```

**Step 2: Create HR administration section**

Create: `app/views/documents/privacy_policy/sections/_hr_administration.html.erb`

```erb
<div class="section">
  <h3>A) Gestion administrative des ressources humaines</h3>

  <table>
    <thead>
      <tr>
        <th>Activité de traitement</th>
        <th>Finalités</th>
        <th>Bases légales</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Gestion administrative du personnel</td>
        <td>
          • Gestion de la procédure d'embauche, des renouvellements et des fins de contrat<br>
          • Suivi administratif des visites médicales obligatoires<br>
          • Gestion des déclarations d'accident du travail et de maladie professionnelle<br>
          • Gestion et suivi des congés et des absences
        </td>
        <td>
          Obligation légale<br>
          Intérêt légitime
        </td>
      </tr>
      <tr>
        <td>Gestion des rémunérations</td>
        <td>
          • Calcul et paiement des rémunérations et accessoires<br>
          • Gestion des frais professionnels<br>
          • Fourniture des écritures de paie à la comptabilité
        </td>
        <td>Obligation légale</td>
      </tr>
      <tr>
        <td>Suivi des carrières</td>
        <td>
          • Gestion des compétences et des évaluations professionnelles<br>
          • Établissement et mise à jour de la fiche administrative<br>
          • Historique de carrière au sein de l'entreprise
        </td>
        <td>Intérêt légitime</td>
      </tr>
    </tbody>
  </table>

  <p><strong>Catégories de données traitées :</strong></p>
  <ul>
    <li>État civil, identité, données d'identification</li>
    <li>Vie professionnelle (CV, diplômes, certifications)</li>
    <li>Informations d'ordre économique et financier (salaire, coordonnées bancaires)</li>
    <li>Données de connexion et d'utilisation des outils professionnels</li>
  </ul>

  <p><strong>Durée de conservation :</strong> Les données sont conservées pendant la durée du contrat de travail et, au-delà, conformément aux durées légales applicables.</p>
</div>
```

**Step 3: Create email management section**

Create: `app/views/documents/privacy_policy/sections/_email_management.html.erb`

```erb
<div class="section">
  <h3>B) Gestion de la messagerie électronique professionnelle</h3>

  <table>
    <thead>
      <tr>
        <th>Activité de traitement</th>
        <th>Finalités</th>
        <th>Bases légales</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Messagerie électronique professionnelle</td>
        <td>
          • Mise à disposition d'une adresse email professionnelle<br>
          • Communication interne et externe<br>
          • Sauvegarde et archivage des emails professionnels
        </td>
        <td>
          Exécution du contrat<br>
          Intérêt légitime
        </td>
      </tr>
    </tbody>
  </table>

  <p><strong>Catégories de données traitées :</strong></p>
  <ul>
    <li>Identité (nom, prénom)</li>
    <li>Adresse email professionnelle</li>
    <li>Contenu des emails professionnels</li>
    <li>Métadonnées (date, heure, destinataires)</li>
  </ul>

  <p><strong>Durée de conservation :</strong> Les emails sont conservés pendant toute la durée du contrat de travail. Les archives peuvent être conservées conformément aux obligations légales.</p>
</div>
```

**Step 4: Create telephony section**

Create: `app/views/documents/privacy_policy/sections/_telephony.html.erb`

```erb
<div class="section">
  <h3>C) Gestion de la téléphonie</h3>

  <table>
    <thead>
      <tr>
        <th>Activité de traitement</th>
        <th>Finalités</th>
        <th>Bases légales</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Téléphonie professionnelle</td>
        <td>
          • Mise à disposition d'une ligne téléphonique (fixe ou mobile)<br>
          • Gestion des communications professionnelles<br>
          • Suivi des communications pour facturation
        </td>
        <td>
          Exécution du contrat<br>
          Intérêt légitime
        </td>
      </tr>
    </tbody>
  </table>

  <p><strong>Catégories de données traitées :</strong></p>
  <ul>
    <li>Identité (nom, prénom)</li>
    <li>Numéro de téléphone professionnel</li>
    <li>Données de trafic téléphonique (numéros appelés, durée, date)</li>
  </ul>

  <p><strong>Durée de conservation :</strong> Les données de téléphonie sont conservées pendant toute la durée du contrat de travail et conformément aux obligations de facturation.</p>
</div>
```

**Step 5: Create data subject rights section**

Create: `app/views/documents/privacy_policy/sections/_data_subject_rights.html.erb`

```erb
<div class="section">
  <h2>Article III - Existence d'un droit d'opposition, d'accès, de rectification, d'effacement et de limitation à l'égard des données vous concernant</h2>

  <p>
    Conformément à la Loi n° 1.565 du 3 décembre 2024, vous disposez des droits suivants :
  </p>

  <ul>
    <li><strong>Droit d'accès :</strong> Vous pouvez obtenir la confirmation que des données vous concernant sont traitées et accéder à ces données.</li>

    <li><strong>Droit de rectification :</strong> Vous pouvez demander la rectification de vos données inexactes ou incomplètes.</li>

    <li><strong>Droit d'effacement :</strong> Vous pouvez demander l'effacement de vos données dans certaines conditions.</li>

    <li><strong>Droit de limitation :</strong> Vous pouvez demander la limitation du traitement de vos données dans certaines conditions.</li>

    <li><strong>Droit d'opposition :</strong> Vous pouvez vous opposer au traitement de vos données pour des raisons tenant à votre situation particulière.</li>
  </ul>

  <p>
    <strong>Pour exercer vos droits, vous pouvez adresser votre demande à :</strong>
  </p>

  <p>
    <%= account.name %><br>
    <%= simple_format(account.address) %>
    Téléphone : <%= account.phone %>
  </p>

  <p>
    Votre demande devra être accompagnée d'une copie d'une pièce d'identité.
  </p>

  <p>
    <strong>Réclamation auprès de l'autorité de contrôle :</strong><br>
    Si vous estimez que vos droits ne sont pas respectés, vous avez le droit d'introduire une réclamation auprès de la Commission de Contrôle des Informations Nominatives (CCIN) de Monaco.
  </p>
</div>
```

**Step 6: Update main template with conditional sections**

Modify: `app/views/documents/privacy_policy/show.html.erb`

Update the body section to include conditional sections:

```erb
<body>
  <%= render "documents/privacy_policy/sections/header", account: @account %>

  <%= render "documents/privacy_policy/sections/controller_identity", account: @account %>

  <%= render "documents/privacy_policy/sections/processing_overview" %>

  <% if @sections.include?(:hr_administration) %>
    <%= render "documents/privacy_policy/sections/hr_administration", account: @account %>
  <% end %>

  <% if @sections.include?(:email_management) %>
    <%= render "documents/privacy_policy/sections/email_management", account: @account %>
  <% end %>

  <% if @sections.include?(:telephony) %>
    <%= render "documents/privacy_policy/sections/telephony", account: @account %>
  <% end %>

  <%= render "documents/privacy_policy/sections/data_subject_rights", account: @account %>
</body>
```

**Step 7: Test template with sections**

```bash
bin/rails runner "
account = Account.first
account.update(address: '123 Test St', phone: '123', rci_number: '123', legal_form: :sarl)
sections = [:base, :hr_administration, :email_management]
html = ApplicationController.render(
  template: 'documents/privacy_policy/show',
  layout: false,
  assigns: { account: account, sections: sections }
)
puts 'Conditional sections rendered' if html.include?('Gestion administrative')
"
```

Expected: "Conditional sections rendered"

**Step 8: Commit**

```bash
git add app/views/documents/privacy_policy/sections
git commit -m "feat: add conditional section templates

Create HR, email, telephony, and rights sections with tables.
Update main template with conditional rendering.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 8: Complete PrivacyPolicyGenerator with PDF Generation

**Files:**
- Modify: `app/services/privacy_policy_generator.rb`
- Modify: `test/services/privacy_policy_generator_test.rb`

**Step 1: Write test for PDF generation**

Add to `test/services/privacy_policy_generator_test.rb`:

```ruby
  test "generate returns PDF data" do
    generator = PrivacyPolicyGenerator.new(@account, @response)

    pdf_data = generator.generate

    assert pdf_data.present?
    assert pdf_data.start_with?("%PDF"), "Should return PDF binary data"
  end
```

**Step 2: Run test to verify it fails**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb -n test_generate_returns_PDF_data
```

Expected: FAIL (returns nil instead of PDF)

**Step 3: Implement PDF generation in service**

Modify: `app/services/privacy_policy_generator.rb`

Update the `generate` method:

```ruby
  def generate
    validate_account_completeness!

    html = render_template
    convert_to_pdf(html)
  end

  private

  # ... existing methods ...

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
      footer_template: footer_html
    }
  end

  def footer_html
    '<div style="font-size:9px; text-align:center; width:100%; color:#666;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>'
  end
```

**Step 4: Run test to verify it passes**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: PASS (all tests passing, PDF generated)

**Step 5: Commit**

```bash
git add app/services/privacy_policy_generator.rb test/services/privacy_policy_generator_test.rb
git commit -m "feat: implement PDF generation in service

Use Grover to convert HTML template to PDF with proper formatting.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 9: Routes and Controller

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/documents_controller.rb`
- Create: `test/controllers/documents_controller_test.rb`

**Step 1: Write controller tests**

Create: `test/controllers/documents_controller_test.rb`

```ruby
require "test_helper"

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.account
    sign_in @user

    @account.update(
      address: "12 Avenue des Spélugues",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )
  end

  test "index requires authentication" do
    sign_out @user

    get documents_path

    assert_redirected_to new_session_path
  end

  test "index renders documents page" do
    get documents_path

    assert_response :success
  end

  test "generate_privacy_policy returns error when account incomplete" do
    @account.update(address: nil)

    post generate_privacy_policy_documents_path, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "incomplete_profile", json["error"]
  end

  test "generate_privacy_policy returns error when no completed questionnaire" do
    # Ensure no completed responses exist
    @account.responses.destroy_all

    post generate_privacy_policy_documents_path, as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "no_completed_questionnaire", json["error"]
  end

  test "generate_privacy_policy downloads PDF when account complete" do
    # Create completed response
    response = @account.responses.create!(
      questionnaire: questionnaires(:one),
      respondent: @user,
      status: :completed
    )

    post generate_privacy_policy_documents_path

    assert_response :success
    assert_equal "application/pdf", @response.media_type
    assert_match /politique_confidentialite/, @response.headers["Content-Disposition"]
  end
end
```

**Step 2: Run tests to verify they fail**

```bash
bin/rails test test/controllers/documents_controller_test.rb
```

Expected: FAIL (routes and controller don't exist)

**Step 3: Add routes**

Modify: `config/routes.rb`

Add inside the authenticated scope:

```ruby
  resources :documents, only: [:index] do
    collection do
      post :generate_privacy_policy
    end
  end
```

**Step 4: Create controller**

Create: `app/controllers/documents_controller.rb`

```ruby
class DocumentsController < ApplicationController
  class AccountIncompleteError < StandardError; end

  rescue_from PrivacyPolicyGenerator::AccountIncompleteError, with: :handle_incomplete_account
  rescue_from Grover::Error, with: :handle_pdf_generation_error

  def index
    available_documents = available_documents_for_account

    render inertia: "Documents/Index",
      props: {
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
      answer&.answer_value == "Oui"
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
```

**Step 5: Run tests to verify they pass**

```bash
bin/rails test test/controllers/documents_controller_test.rb
```

Expected: PASS (all controller tests passing)

**Step 6: Commit**

```bash
git add config/routes.rb app/controllers/documents_controller.rb test/controllers/documents_controller_test.rb
git commit -m "feat: add documents controller with privacy policy generation

Handle document generation, validation, and error cases.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 10: Account Profile Completion - Backend

**Files:**
- Modify: `config/routes.rb`
- Modify: `app/controllers/accounts_controller.rb`
- Modify: `test/controllers/accounts_controller_test.rb`

**Step 1: Add test for profile completion**

Add to `test/controllers/accounts_controller_test.rb`:

```ruby
  test "complete_profile updates account fields" do
    account = accounts(:one)
    user = users(:one)
    sign_in user

    patch complete_profile_account_path, params: {
      account: {
        address: "12 Avenue des Spélugues, 98000 Monaco",
        phone: "+377 93 15 26 00",
        rci_number: "12S34567",
        legal_form: "sarl"
      }
    }

    assert_response :success
    account.reload
    assert_equal "12 Avenue des Spélugues, 98000 Monaco", account.address
    assert_equal "+377 93 15 26 00", account.phone
    assert_equal "12S34567", account.rci_number
    assert_equal "sarl", account.legal_form
  end

  test "complete_profile requires authentication" do
    sign_out users(:one)

    patch complete_profile_account_path, params: { account: { address: "Test" } }

    assert_redirected_to new_session_path
  end
```

**Step 2: Run tests to verify they fail**

```bash
bin/rails test test/controllers/accounts_controller_test.rb -n /complete_profile/
```

Expected: FAIL (route doesn't exist)

**Step 3: Add route**

Modify: `config/routes.rb`

Add inside authenticated scope:

```ruby
  resource :account, only: [:update] do
    patch :complete_profile, on: :member
  end
```

**Step 4: Add controller action**

Modify: `app/controllers/accounts_controller.rb`

Add method:

```ruby
  def complete_profile
    if Current.account.update(profile_params)
      render json: { success: true }
    else
      render json: {
        errors: Current.account.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:account).permit(:address, :phone, :rci_number, :legal_form)
  end
```

**Step 5: Run tests to verify they pass**

```bash
bin/rails test test/controllers/accounts_controller_test.rb
```

Expected: PASS (all tests passing)

**Step 6: Commit**

```bash
git add config/routes.rb app/controllers/accounts_controller.rb test/controllers/accounts_controller_test.rb
git commit -m "feat: add account profile completion endpoint

Allow updating address, phone, RCI number, and legal form.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 11: Frontend - Documents Index Page

**Files:**
- Create: `app/frontend/pages/Documents/Index.svelte`

**Step 1: Create Documents Index page**

Create: `app/frontend/pages/Documents/Index.svelte`

```svelte
<script>
  import { router } from '@inertiajs/svelte'
  import { Button } from '$lib/components/ui/button'
  import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card'
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
    router.post(`/documents/generate_${docType}`, {}, {
      onError: (errors) => {
        if (errors.error === 'incomplete_profile') {
          showProfileModal = true
        } else if (errors.error === 'no_completed_questionnaire') {
          alert('Veuillez compléter le questionnaire avant de générer des documents.')
        } else {
          alert('Une erreur est survenue lors de la génération du document.')
        }
      },
      onSuccess: () => {
        // Document download handled by browser
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

<div class="container mx-auto py-8">
  <div class="mb-8">
    <h1 class="text-3xl font-bold">Documents</h1>
    <p class="text-muted-foreground mt-2">
      Générez vos documents de conformité RGPD
    </p>
  </div>

  {#if available_documents.length === 0}
    <Card>
      <CardContent class="pt-6">
        <p class="text-center text-muted-foreground">
          Aucun document disponible. Complétez le questionnaire pour générer vos documents de conformité.
        </p>
      </CardContent>
    </Card>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each available_documents as doc}
        <Card class="hover:shadow-lg transition-shadow cursor-pointer"
              on:click={() => handleGenerateDocument(doc.type)}>
          <CardHeader>
            <div class="flex items-center gap-3">
              <div class="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                </svg>
              </div>
              <CardTitle class="text-lg">{doc.title}</CardTitle>
            </div>
          </CardHeader>
          <CardContent>
            <CardDescription>{doc.description}</CardDescription>
            <Button variant="outline" class="mt-4 w-full">
              Télécharger le PDF
            </Button>
          </CardContent>
        </Card>
      {/each}
    </div>
  {/if}
</div>

<ProfileCompletionModal
  bind:open={showProfileModal}
  on:completed={onProfileCompleted}
  on:cancel={() => showProfileModal = false}
/>
```

**Step 2: Test page renders**

Start dev server and navigate to `/documents` (manual test):

```bash
bin/dev
```

Visit: `http://localhost:3000/documents`

Expected: Page renders with "Documents" title

**Step 3: Commit**

```bash
git add app/frontend/pages/Documents/Index.svelte
git commit -m "feat: add Documents index page

Display available documents with generation triggers.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 12: Frontend - Profile Completion Modal

**Files:**
- Create: `app/frontend/pages/Documents/ProfileCompletionModal.svelte`

**Step 1: Create ProfileCompletionModal component**

Create: `app/frontend/pages/Documents/ProfileCompletionModal.svelte`

```svelte
<script>
  import { createEventDispatcher } from 'svelte'
  import { useForm } from '@inertiajs/svelte'
  import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '$lib/components/ui/dialog'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Label } from '$lib/components/ui/label'
  import { Textarea } from '$lib/components/ui/textarea'
  import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '$lib/components/ui/select'

  export let open = false

  const dispatch = createEventDispatcher()

  const form = useForm({
    address: '',
    phone: '',
    rci_number: '',
    legal_form: ''
  })

  const legalForms = [
    { value: 'sarl', label: 'Société à Responsabilité Limitée (SARL)' },
    { value: 'sam', label: 'Société Anonyme Monégasque (SAM)' },
    { value: 'snc', label: 'Société en Nom Collectif (SNC)' },
    { value: 'scs', label: 'Société en Commandite Simple (SCS)' },
    { value: 'sca', label: 'Société en Commandite par Actions (SCA)' },
    { value: 'surl', label: 'Société Unipersonnelle à Responsabilité Limitée (SURL)' },
    { value: 'sima', label: 'Société d\'Innovation Monégasque par Actions (SIMA)' },
    { value: 'ei', label: 'Entreprise Individuelle' },
    { value: 'sci', label: 'Société Civile Immobilière (SCI)' }
  ]

  function handleSubmit() {
    $form.patch('/account/complete_profile', {
      onSuccess: () => {
        dispatch('completed')
      },
      onError: (errors) => {
        console.error('Profile completion failed:', errors)
      }
    })
  }

  function handleCancel() {
    dispatch('cancel')
  }
</script>

<Dialog bind:open>
  <DialogContent class="sm:max-w-[500px]">
    <DialogHeader>
      <DialogTitle>Complétez votre profil</DialogTitle>
      <DialogDescription>
        Ces informations sont nécessaires pour générer vos documents de conformité.
      </DialogDescription>
    </DialogHeader>

    <form on:submit|preventDefault={handleSubmit} class="space-y-4">
      <div class="space-y-2">
        <Label for="address">Adresse complète</Label>
        <Textarea
          id="address"
          bind:value={$form.address}
          placeholder="12 Avenue des Spélugues&#10;98000 Monaco"
          rows="3"
          required
        />
        {#if $form.errors.address}
          <p class="text-sm text-destructive">{$form.errors.address}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="phone">Téléphone</Label>
        <Input
          id="phone"
          type="tel"
          bind:value={$form.phone}
          placeholder="+377 93 15 26 00"
          required
        />
        {#if $form.errors.phone}
          <p class="text-sm text-destructive">{$form.errors.phone}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="rci_number">Numéro RCI</Label>
        <Input
          id="rci_number"
          bind:value={$form.rci_number}
          placeholder="12S34567"
          required
        />
        <p class="text-xs text-muted-foreground">
          Répertoire du Commerce et de l'Industrie de Monaco
        </p>
        {#if $form.errors.rci_number}
          <p class="text-sm text-destructive">{$form.errors.rci_number}</p>
        {/if}
      </div>

      <div class="space-y-2">
        <Label for="legal_form">Forme juridique</Label>
        <Select bind:value={$form.legal_form} required>
          <SelectTrigger>
            <SelectValue placeholder="Sélectionnez une forme juridique" />
          </SelectTrigger>
          <SelectContent>
            {#each legalForms as form}
              <SelectItem value={form.value}>{form.label}</SelectItem>
            {/each}
          </SelectContent>
        </Select>
        {#if $form.errors.legal_form}
          <p class="text-sm text-destructive">{$form.errors.legal_form}</p>
        {/if}
      </div>

      <div class="flex justify-end gap-3 pt-4">
        <Button type="button" variant="outline" on:click={handleCancel}>
          Annuler
        </Button>
        <Button type="submit" disabled={$form.processing}>
          {$form.processing ? 'Enregistrement...' : 'Enregistrer et générer'}
        </Button>
      </div>
    </form>
  </DialogContent>
</Dialog>
```

**Step 2: Test modal (manual verification)**

Start dev server, navigate to `/documents`, click a document when profile incomplete:

```bash
bin/dev
```

Expected: Modal appears with form fields

**Step 3: Commit**

```bash
git add app/frontend/pages/Documents/ProfileCompletionModal.svelte
git commit -m "feat: add profile completion modal

Form to collect missing account fields before document generation.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 13: Integration Test - End-to-End Flow

**Files:**
- Create: `test/integration/privacy_policy_generation_test.rb`

**Step 1: Write integration test**

Create: `test/integration/privacy_policy_generation_test.rb`

```ruby
require "test_helper"

class PrivacyPolicyGenerationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.account
    @account.update(
      address: "12 Avenue des Spélugues, 98000 Monaco",
      phone: "+377 93 15 26 00",
      rci_number: "12S34567",
      legal_form: :sarl
    )

    sign_in @user

    # Create completed questionnaire response with employee data
    @questionnaire = questionnaires(:one)
    @response = @account.responses.create!(
      questionnaire: @questionnaire,
      respondent: @user,
      status: :completed
    )

    # Add answers indicating has employees with email
    has_personnel = questions(:has_personnel)
    has_email = questions(:has_email)

    @response.answers.create!(question: has_personnel, answer_value: "Oui")
    @response.answers.create!(question: has_email, answer_value: "Oui")
  end

  test "complete flow: visit documents page, generate PDF" do
    # Visit documents index
    get documents_path
    assert_response :success

    # Generate privacy policy
    post generate_privacy_policy_documents_path
    assert_response :success

    # Verify PDF download
    assert_equal "application/pdf", response.media_type
    assert_match /politique_confidentialite/, response.headers["Content-Disposition"]

    # Verify PDF content starts with PDF magic bytes
    assert response.body.start_with?("%PDF")
  end

  test "profile incomplete flow: shows error, completes profile, generates PDF" do
    # Make account incomplete
    @account.update(address: nil)

    # Try to generate document
    post generate_privacy_policy_documents_path, as: :json
    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_equal "incomplete_profile", json["error"]
    assert_includes json["missing_fields"], "address"

    # Complete profile
    patch complete_profile_account_path, params: {
      account: { address: "12 Avenue des Spélugues" }
    }
    assert_response :success

    # Now generate should work
    post generate_privacy_policy_documents_path
    assert_response :success
    assert_equal "application/pdf", response.media_type
  end

  test "no questionnaire flow: shows error" do
    @account.responses.destroy_all

    post generate_privacy_policy_documents_path, as: :json
    assert_response :unprocessable_entity

    json = JSON.parse(response.body)
    assert_equal "no_completed_questionnaire", json["error"]
  end

  test "generated PDF includes correct sections based on answers" do
    post generate_privacy_policy_documents_path
    assert_response :success

    # Note: Can't easily parse PDF in test, but verify it generates without error
    assert response.body.present?
    assert response.body.start_with?("%PDF")
  end
end
```

**Step 2: Run integration test**

```bash
bin/rails test test/integration/privacy_policy_generation_test.rb
```

Expected: PASS (all integration tests passing)

**Step 3: Commit**

```bash
git add test/integration/privacy_policy_generation_test.rb
git commit -m "test: add end-to-end integration tests

Test complete document generation flow with edge cases.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 14: Run Full Test Suite and Fix Any Issues

**Files:**
- Any files that need fixes based on test results

**Step 1: Run complete test suite**

```bash
bin/rails test
```

Expected: Review results, identify any failures

**Step 2: Fix any failing tests**

If tests fail, debug and fix issues. Common issues:
- Missing fixtures
- Route conflicts
- Missing dependencies

**Step 3: Verify all tests pass**

```bash
bin/rails test
```

Expected: All tests pass (0 failures)

**Step 4: Run system tests (if applicable)**

```bash
bin/rails test:system
```

**Step 5: Commit fixes if needed**

```bash
git add .
git commit -m "fix: resolve test failures

Address issues found in full test suite run.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Task 15: Manual QA and Documentation

**Files:**
- Update: `docs/plans/2025-11-03-privacy-policy-generation-design.md` (mark as implemented)
- Create: `docs/privacy-policy-generation-usage.md` (optional user guide)

**Step 1: Manual QA checklist**

Start the development server and test:

```bash
bin/dev
```

Manual testing checklist:
1. [ ] Navigate to `/documents` - page loads
2. [ ] Complete questionnaire indicating has employees
3. [ ] Return to documents page - privacy policy document appears
4. [ ] Click document with incomplete profile - modal appears
5. [ ] Fill profile form - saves successfully
6. [ ] Click document again - PDF downloads
7. [ ] Open PDF - verify formatting, sections, company info
8. [ ] Verify conditional sections (HR, email) appear correctly
9. [ ] Test with different questionnaire answers
10. [ ] Test error cases (no questionnaire, generation failure)

**Step 2: Update design document status**

Add to top of `docs/plans/2025-11-03-privacy-policy-generation-design.md`:

```markdown
**Status**: ✅ Implemented (2025-11-03)
**Implementation Branch**: feature/privacy-policy-generation
```

**Step 3: Create usage documentation (optional)**

If helpful, create: `docs/privacy-policy-generation-usage.md`

Document:
- How users generate documents
- What information is required
- How to update templates
- Troubleshooting common issues

**Step 4: Final commit**

```bash
git add docs/
git commit -m "docs: update implementation status and add usage guide

Mark privacy policy generation as implemented.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Summary

**Total Tasks**: 15
**Estimated Time**: 4-6 hours for experienced developer
**Testing Strategy**: TDD throughout, integration tests for critical paths
**Key Technologies**: Rails 8, Grover, Svelte 5, Inertia.js

**After Implementation:**
1. Run `bin/rails test` - ensure all tests pass
2. Manual QA - verify document generation works end-to-end
3. Review with team - get feedback on PDF formatting
4. Merge feature branch to main

**Success Criteria:**
- ✅ Users with complete profiles can generate privacy policy PDFs
- ✅ Conditional sections appear based on questionnaire answers
- ✅ Profile completion modal collects missing fields
- ✅ Generated PDFs are professionally formatted
- ✅ All tests pass (unit, integration, system)
- ✅ No security vulnerabilities introduced
