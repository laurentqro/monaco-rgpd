# Monaco RGPD Platform - MVP Implementation Plan

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Build Monaco's first comprehensive GDPR compliance SaaS platform helping solopreneurs/SMEs achieve full compliance with Loi n° 1.565 through guided questionnaires, document generation, and APDP-compliant Article 30 registers.

**Architecture:** Rails 8 + Inertia.js + Svelte 5 multi-tenant SaaS built on rails-saas-starter foundation. Master questionnaire seeded in database, multiple responses per account for compliance tracking, nested Article 30 register structure matching APDP requirements, background document generation with Liquid templates.

**Tech Stack:** Rails 8.0.3, PostgreSQL 18, Inertia.js, Svelte 5, Tailwind CSS, SolidQueue, Liquid templating, Prawn (PDF generation)

---

## Phase 1: Project Setup & Foundation

### Task 1: Clone Starter Kit and Configure Project

**Files:**
- Clone: `rails-saas-starter` → `monaco-rgpd`
- Modify: `config/application.rb`
- Modify: `config/locales/fr.yml`
- Modify: `README.md`

**Step 1: Clone the starter kit**

```bash
cd /Users/laurentcurau/projects
cp -r rails-saas-starter monaco-rgpd
cd monaco-rgpd
rm -rf .git
git init
git add .
git commit -m "Initial commit from rails-saas-starter"
```

**Step 2: Update application name**

In `config/application.rb:6`:
```ruby
module MonacoRgpd
  class Application < Rails::Application
```

**Step 3: Configure French as default locale**

In `config/application.rb` (inside config block):
```ruby
config.i18n.default_locale = :fr
config.i18n.available_locales = [:fr]
```

**Step 4: Create French locale file**

Create `config/locales/fr.yml`:
```yaml
fr:
  application_name: "Monaco RGPD"
  tagline: "Votre conformité RGPD simplifiée"
```

**Step 5: Update README**

Replace `README.md` content with:
```markdown
# Monaco RGPD

Plateforme SaaS de conformité RGPD pour Monaco - Conforme à la Loi n° 1.565

## Stack Technique

- Rails 8.0.3
- PostgreSQL 18
- Inertia.js + Svelte 5
- Tailwind CSS

## Démarrage

```bash
bin/setup
bin/dev
```

## Documentation

- [Plan d'implémentation](docs/plans/2025-10-14-monaco-rgpd-mvp.md)
```

**Step 6: Commit**

```bash
git add .
git commit -m "chore: configure Monaco RGPD project with French locale"
```

---

### Task 2: Extend Account Model for Monaco RGPD

**Files:**
- Create: `db/migrate/XXXXXX_add_monaco_rgpd_fields_to_accounts.rb`
- Modify: `app/models/account.rb`
- Create: `test/models/account_test.rb` (add tests)

**Step 1: Write failing tests**

In `test/models/account_test.rb`, add:
```ruby
test "should have valid account_type" do
  account = accounts(:one)
  account.account_type = :solopreneur
  assert account.valid?
end

test "should have valid entity_type" do
  account = accounts(:one)
  account.entity_type = :company
  assert account.valid?
end

test "should default to simple compliance_mode for solopreneur" do
  account = Account.create!(
    name: "Test Solopreneur",
    subdomain: "test-solo",
    account_type: :solopreneur
  )
  assert_equal :simple, account.compliance_mode
end

test "should require jurisdiction" do
  account = Account.new(name: "Test", subdomain: "test")
  account.jurisdiction = nil
  assert_not account.valid?
end
```

**Step 2: Run tests to verify they fail**

```bash
rails test test/models/account_test.rb
```
Expected: FAIL with "undefined method" errors

**Step 3: Create migration**

```bash
rails generate migration AddMonacoRgpdFieldsToAccounts
```

In the generated migration file:
```ruby
class AddMonacoRgpdFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :account_type, :integer, default: 0, null: false
    add_column :accounts, :compliance_mode, :integer, default: 0, null: false
    add_column :accounts, :entity_type, :integer
    add_column :accounts, :jurisdiction, :string, default: "MC", null: false
    add_column :accounts, :activity_sector, :string
    add_column :accounts, :employee_count, :integer
    add_column :accounts, :metadata, :jsonb, default: {}

    add_index :accounts, :account_type
    add_index :accounts, :jurisdiction
  end
end
```

**Step 4: Run migration**

```bash
rails db:migrate
```

**Step 5: Add enums and validations to Account model**

In `app/models/account.rb`, add after line 1:
```ruby
class Account < ApplicationRecord
  # Existing associations...

  enum :account_type, {
    solopreneur: 0,
    company: 1,
    consultant: 2
  }, prefix: true

  enum :compliance_mode, {
    simple: 0,
    modular: 1
  }, prefix: true

  enum :entity_type, {
    company: 0,
    ngo: 1,
    government: 2,
    association: 3
  }, prefix: true

  validates :jurisdiction, presence: true
  validates :account_type, presence: true

  # Set compliance_mode based on account_type
  before_validation :set_compliance_mode, on: :create

  private

  def set_compliance_mode
    self.compliance_mode ||= account_type_solopreneur? ? :simple : :modular
  end
end
```

**Step 6: Run tests to verify they pass**

```bash
rails test test/models/account_test.rb
```
Expected: PASS

**Step 7: Commit**

```bash
git add .
git commit -m "feat: add Monaco RGPD fields to accounts model"
```

---

## Phase 2: Questionnaire System

### Task 3: Create Questionnaire Models

**Files:**
- Create: `db/migrate/XXXXXX_create_questionnaires.rb`
- Create: `app/models/questionnaire.rb`
- Create: `app/models/section.rb`
- Create: `app/models/question.rb`
- Create: `app/models/answer_choice.rb`
- Create: `app/models/logic_rule.rb`
- Create: `test/models/questionnaire_test.rb`
- Create: `test/fixtures/questionnaires.yml`

**Step 1: Write failing test**

Create `test/models/questionnaire_test.rb`:
```ruby
require "test_helper"

class QuestionnaireTest < ActiveSupport::TestCase
  test "should create questionnaire with sections and questions" do
    questionnaire = Questionnaire.create!(
      title: "Test Questionnaire",
      category: "compliance_assessment",
      status: :published
    )

    section = questionnaire.sections.create!(
      title: "Test Section",
      order_index: 1
    )

    question = section.questions.create!(
      question_text: "Test question?",
      question_type: :yes_no,
      order_index: 1,
      is_required: true
    )

    assert_equal 1, questionnaire.sections.count
    assert_equal 1, section.questions.count
    assert_equal "Test question?", question.question_text
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/models/questionnaire_test.rb
```
Expected: FAIL with "uninitialized constant Questionnaire"

**Step 3: Create migration**

```bash
rails generate migration CreateQuestionnaireSystem
```

In migration file:
```ruby
class CreateQuestionnaireSystem < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaires do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.integer :status, default: 0, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    create_table :sections do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :order_index, null: false

      t.timestamps
    end

    create_table :questions do |t|
      t.references :section, null: false, foreign_key: true
      t.text :question_text, null: false
      t.integer :question_type, null: false
      t.text :help_text
      t.integer :order_index, null: false
      t.boolean :is_required, default: false
      t.jsonb :settings, default: {}
      t.decimal :weight, precision: 5, scale: 2

      t.timestamps
    end

    create_table :answer_choices do |t|
      t.references :question, null: false, foreign_key: true
      t.text :choice_text, null: false
      t.integer :order_index, null: false
      t.decimal :score, precision: 5, scale: 2

      t.timestamps
    end

    create_table :logic_rules do |t|
      t.references :source_question, null: false, foreign_key: { to_table: :questions }
      t.references :target_section, foreign_key: { to_table: :sections }
      t.integer :condition_type, null: false
      t.jsonb :condition_value, default: {}
      t.integer :action, null: false

      t.timestamps
    end

    add_index :questionnaires, :status
    add_index :sections, :order_index
    add_index :questions, :order_index
    add_index :answer_choices, :order_index
  end
end
```

**Step 4: Run migration**

```bash
rails db:migrate
```

**Step 5: Create models**

Create `app/models/questionnaire.rb`:
```ruby
class Questionnaire < ApplicationRecord
  has_many :sections, dependent: :destroy
  has_many :questions, through: :sections
  has_many :responses, dependent: :destroy

  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }, prefix: true

  validates :title, presence: true
  validates :status, presence: true

  scope :published, -> { where(status: :published) }
end
```

Create `app/models/section.rb`:
```ruby
class Section < ApplicationRecord
  belongs_to :questionnaire
  has_many :questions, dependent: :destroy
  has_many :logic_rules, foreign_key: :target_section_id, dependent: :destroy

  validates :title, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
```

Create `app/models/question.rb`:
```ruby
class Question < ApplicationRecord
  belongs_to :section
  has_many :answer_choices, dependent: :destroy
  has_many :logic_rules, foreign_key: :source_question_id, dependent: :destroy
  has_many :answers, dependent: :destroy

  enum :question_type, {
    single_choice: 0,
    multiple_choice: 1,
    text_short: 2,
    text_long: 3,
    yes_no: 4,
    rating_scale: 5
  }, prefix: true

  validates :question_text, presence: true
  validates :question_type, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
```

Create `app/models/answer_choice.rb`:
```ruby
class AnswerChoice < ApplicationRecord
  belongs_to :question

  validates :choice_text, presence: true
  validates :order_index, presence: true, numericality: { only_integer: true }

  default_scope { order(order_index: :asc) }
end
```

Create `app/models/logic_rule.rb`:
```ruby
class LogicRule < ApplicationRecord
  belongs_to :source_question, class_name: "Question"
  belongs_to :target_section, class_name: "Section", optional: true

  enum :condition_type, {
    equals: 0,
    not_equals: 1,
    contains: 2,
    greater_than: 3,
    less_than: 4
  }, prefix: true

  enum :action, {
    show: 0,
    hide: 1,
    skip_to_section: 2
  }, prefix: true

  validates :condition_type, presence: true
  validates :action, presence: true
end
```

**Step 6: Run tests to verify they pass**

```bash
rails test test/models/questionnaire_test.rb
```
Expected: PASS

**Step 7: Commit**

```bash
git add .
git commit -m "feat: create questionnaire system models and migrations"
```

---

### Task 4: Create Response and Answer Models

**Files:**
- Create: `db/migrate/XXXXXX_create_responses_and_answers.rb`
- Create: `app/models/response.rb`
- Create: `app/models/answer.rb`
- Create: `test/models/response_test.rb`

**Step 1: Write failing test**

Create `test/models/response_test.rb`:
```ruby
require "test_helper"

class ResponseTest < ActiveSupport::TestCase
  test "should create response for account" do
    account = accounts(:one)
    questionnaire = questionnaires(:compliance)
    user = users(:one)

    response = Response.create!(
      account: account,
      questionnaire: questionnaire,
      respondent: user,
      status: :in_progress
    )

    assert_equal account, response.account
    assert_equal :in_progress, response.status
  end

  test "should create answers for response" do
    response = responses(:one)
    question = questions(:one)

    answer = response.answers.create!(
      question: question,
      answer_value: { value: "Oui" },
      calculated_score: 100.0
    )

    assert_equal response, answer.response
    assert_equal "Oui", answer.answer_value["value"]
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/models/response_test.rb
```
Expected: FAIL

**Step 3: Create migration**

```bash
rails generate migration CreateResponsesAndAnswers
```

In migration:
```ruby
class CreateResponsesAndAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :questionnaire, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :respondent, null: false, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    create_table :answers do |t|
      t.references :response, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.jsonb :answer_value, default: {}
      t.decimal :calculated_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :responses, :status
    add_index :responses, [:account_id, :created_at]
    add_index :answers, [:response_id, :question_id], unique: true
  end
end
```

**Step 4: Run migration**

```bash
rails db:migrate
```

**Step 5: Create models**

Create `app/models/response.rb`:
```ruby
class Response < ApplicationRecord
  belongs_to :questionnaire
  belongs_to :account
  belongs_to :respondent, class_name: "User"
  has_many :answers, dependent: :destroy
  has_one :compliance_assessment, dependent: :destroy

  enum :status, {
    in_progress: 0,
    completed: 1
  }, prefix: true

  validates :status, presence: true

  before_create :set_started_at

  scope :for_account, ->(account) { where(account: account) }
  scope :completed, -> { where(status: :completed) }

  private

  def set_started_at
    self.started_at ||= Time.current
  end
end
```

Create `app/models/answer.rb`:
```ruby
class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question

  validates :answer_value, presence: true
  validates :question_id, uniqueness: { scope: :response_id }

  # Calculate score based on question type and answer
  after_save :calculate_score

  private

  def calculate_score
    return unless question.weight.present?

    # Score calculation logic will be implemented based on question type
    # For now, store as-is
  end
end
```

**Step 6: Update related models**

In `app/models/account.rb`, add:
```ruby
has_many :responses, dependent: :destroy
```

In `app/models/user.rb`, add:
```ruby
has_many :responses, foreign_key: :respondent_id, dependent: :nullify
```

**Step 7: Run tests to verify they pass**

```bash
rails test test/models/response_test.rb
```
Expected: PASS

**Step 8: Commit**

```bash
git add .
git commit -m "feat: create response and answer models"
```

---

## Phase 3: Compliance Assessment & Scoring

### Task 5: Create Compliance Assessment Models

**Files:**
- Create: `db/migrate/XXXXXX_create_compliance_assessments.rb`
- Create: `app/models/compliance_assessment.rb`
- Create: `app/models/compliance_area.rb`
- Create: `app/models/compliance_area_score.rb`
- Create: `test/models/compliance_assessment_test.rb`

**Step 1: Write failing test**

Create `test/models/compliance_assessment_test.rb`:
```ruby
require "test_helper"

class ComplianceAssessmentTest < ActiveSupport::TestCase
  test "should calculate risk level based on score" do
    response = responses(:one)

    assessment = ComplianceAssessment.create!(
      response: response,
      account: response.account,
      overall_score: 75.0,
      max_possible_score: 100.0,
      status: :completed
    )

    assert_equal "attention_required", assessment.risk_level
  end

  test "should have compliance area scores" do
    assessment = compliance_assessments(:one)
    area = compliance_areas(:lawfulness)

    area_score = assessment.compliance_area_scores.create!(
      compliance_area: area,
      score: 82.0,
      max_score: 100.0
    )

    assert_equal 82.0, area_score.score
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/models/compliance_assessment_test.rb
```
Expected: FAIL

**Step 3: Create migration**

```bash
rails generate migration CreateComplianceAssessments
```

In migration:
```ruby
class CreateComplianceAssessments < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_areas do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps
    end

    create_table :compliance_assessments do |t|
      t.references :response, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.decimal :overall_score, precision: 5, scale: 2
      t.decimal :max_possible_score, precision: 5, scale: 2
      t.string :risk_level
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    create_table :compliance_area_scores do |t|
      t.references :compliance_assessment, null: false, foreign_key: true
      t.references :compliance_area, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2
      t.decimal :max_score, precision: 5, scale: 2

      t.timestamps
    end

    add_index :compliance_areas, :code, unique: true
    add_index :compliance_assessments, :status
    add_index :compliance_assessments, [:account_id, :created_at]
  end
end
```

**Step 4: Run migration**

```bash
rails db:migrate
```

**Step 5: Create models**

Create `app/models/compliance_area.rb`:
```ruby
class ComplianceArea < ApplicationRecord
  has_many :compliance_area_scores, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
```

Create `app/models/compliance_assessment.rb`:
```ruby
class ComplianceAssessment < ApplicationRecord
  belongs_to :response
  belongs_to :account
  has_many :compliance_area_scores, dependent: :destroy
  has_many :compliance_areas, through: :compliance_area_scores

  enum :status, {
    draft: 0,
    completed: 1
  }, prefix: true

  validates :overall_score, presence: true
  validates :max_possible_score, presence: true

  before_save :calculate_risk_level

  scope :for_account, ->(account) { where(account: account) }
  scope :completed, -> { where(status: :completed) }

  private

  def calculate_risk_level
    percentage = (overall_score / max_possible_score * 100).round

    self.risk_level = case percentage
    when 85..100 then "compliant"
    when 60..84 then "attention_required"
    else "non_compliant"
    end
  end
end
```

Create `app/models/compliance_area_score.rb`:
```ruby
class ComplianceAreaScore < ApplicationRecord
  belongs_to :compliance_assessment
  belongs_to :compliance_area

  validates :score, presence: true
  validates :max_score, presence: true

  def percentage
    (score / max_score * 100).round(1)
  end
end
```

**Step 6: Update related models**

In `app/models/response.rb`, add:
```ruby
has_one :compliance_assessment, dependent: :destroy
```

In `app/models/account.rb`, add:
```ruby
has_many :compliance_assessments, dependent: :destroy
```

**Step 7: Run tests to verify they pass**

```bash
rails test test/models/compliance_assessment_test.rb
```
Expected: PASS

**Step 8: Commit**

```bash
git add .
git commit -m "feat: create compliance assessment and scoring models"
```

---

## Phase 4: Document Generation System

### Task 6: Create Document and Template Models

**Files:**
- Create: `db/migrate/XXXXXX_create_documents_and_templates.rb`
- Create: `app/models/document.rb`
- Create: `app/models/document_template.rb`
- Create: `app/models/document_template_version.rb`
- Create: `test/models/document_test.rb`
- Create: `Gemfile` (add liquid gem)

**Step 1: Add Liquid gem**

In `Gemfile`, add:
```ruby
gem "liquid", "~> 5.5"
gem "prawn", "~> 2.4"
gem "prawn-table", "~> 0.2"
```

Run:
```bash
bundle install
```

**Step 2: Write failing test**

Create `test/models/document_test.rb`:
```ruby
require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  test "should create document for response" do
    account = accounts(:one)
    response = responses(:one)

    document = Document.create!(
      account: account,
      response: response,
      document_type: :privacy_policy,
      title: "Politique de confidentialité - Test",
      status: :generating
    )

    assert_equal :privacy_policy, document.document_type
    assert_equal :generating, document.status
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
end
```

**Step 3: Run test to verify it fails**

```bash
rails test test/models/document_test.rb
```
Expected: FAIL

**Step 4: Create migration**

```bash
rails generate migration CreateDocumentsAndTemplates
```

In migration:
```ruby
class CreateDocumentsAndTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :document_templates do |t|
      t.integer :document_type, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :version, default: 1, null: false
      t.boolean :is_active, default: false
      t.bigint :created_by_id

      t.timestamps
    end

    create_table :document_template_versions do |t|
      t.references :document_template, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :version, null: false
      t.bigint :changed_by_id
      t.text :change_notes

      t.timestamps
    end

    create_table :documents do |t|
      t.references :account, null: false, foreign_key: true
      t.references :response, null: false, foreign_key: true
      t.integer :document_type, null: false
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.datetime :generated_at

      t.timestamps
    end

    add_index :document_templates, :document_type
    add_index :document_templates, :is_active
    add_index :documents, :document_type
    add_index :documents, :status
    add_index :documents, [:account_id, :created_at]
  end
end
```

**Step 5: Run migration**

```bash
rails db:migrate
```

**Step 6: Create models**

Create `app/models/document_template.rb`:
```ruby
class DocumentTemplate < ApplicationRecord
  has_many :document_template_versions, dependent: :destroy

  enum :document_type, {
    privacy_policy: 0,
    processing_register: 1,
    consent_form: 2,
    employee_notice: 3
  }, prefix: true

  validates :title, presence: true
  validates :content, presence: true
  validates :document_type, presence: true
  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(is_active: true) }

  # Create version snapshot before updating
  before_update :create_version_snapshot, if: :content_changed?

  def render(context)
    template = Liquid::Template.parse(content)
    template.render(context)
  end

  private

  def create_version_snapshot
    document_template_versions.create!(
      content: content_was,
      version: version_was,
      changed_by_id: created_by_id
    )
    self.version += 1
  end
end
```

Create `app/models/document_template_version.rb`:
```ruby
class DocumentTemplateVersion < ApplicationRecord
  belongs_to :document_template

  validates :content, presence: true
  validates :version, presence: true
end
```

Create `app/models/document.rb`:
```ruby
class Document < ApplicationRecord
  belongs_to :account
  belongs_to :response
  has_one_attached :pdf_file

  enum :document_type, {
    privacy_policy: 0,
    processing_register: 1,
    consent_form: 2,
    employee_notice: 3
  }, prefix: true

  enum :status, {
    generating: 0,
    ready: 1,
    failed: 2
  }, prefix: true

  validates :title, presence: true
  validates :document_type, presence: true
  validates :status, presence: true

  scope :for_account, ->(account) { where(account: account) }
  scope :ready, -> { where(status: :ready) }
end
```

**Step 7: Update related models**

In `app/models/account.rb`, add:
```ruby
has_many :documents, dependent: :destroy
```

In `app/models/response.rb`, add:
```ruby
has_many :documents, dependent: :destroy
```

**Step 8: Run tests to verify they pass**

```bash
rails test test/models/document_test.rb
```
Expected: PASS

**Step 9: Commit**

```bash
git add .
git commit -m "feat: create document and template models with Liquid support"
```

---

## Phase 5: Article 30 Register (APDP-Compliant)

### Task 7: Create Processing Activity Models

**Files:**
- Create: `db/migrate/XXXXXX_create_processing_activities.rb`
- Create: `app/models/processing_activity.rb`
- Create: `app/models/processing_purpose.rb`
- Create: `app/models/data_category_detail.rb`
- Create: `app/models/access_category.rb`
- Create: `app/models/recipient_category.rb`
- Create: `test/models/processing_activity_test.rb`

**Step 1: Write failing test**

Create `test/models/processing_activity_test.rb`:
```ruby
require "test_helper"

class ProcessingActivityTest < ActiveSupport::TestCase
  test "should create processing activity with nested structures" do
    account = accounts(:one)

    activity = ProcessingActivity.create!(
      account: account,
      name: "Gestion administrative des salariés",
      has_dpo: true,
      surveillance_purpose: false,
      data_subjects: ["employees"],
      sensitive_data: false
    )

    purpose = activity.processing_purposes.create!(
      purpose_number: 1,
      purpose_name: "Gestion de la procédure d'embauche",
      legal_basis: :contract,
      order_index: 1
    )

    data_category = activity.data_category_details.create!(
      category_type: :identity_family,
      detail: "Nom, prénom, date de naissance",
      retention_period: "Tant que la personne est en poste",
      data_source: "Personnes concernées + Service RH"
    )

    assert_equal 1, activity.processing_purposes.count
    assert_equal 1, activity.data_category_details.count
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/models/processing_activity_test.rb
```
Expected: FAIL

**Step 3: Create migration**

```bash
rails generate migration CreateProcessingActivities
```

In migration:
```ruby
class CreateProcessingActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :processing_activities do |t|
      t.references :account, null: false, foreign_key: true
      t.references :response, foreign_key: true
      t.string :name, null: false
      t.text :description

      # Organization structure
      t.boolean :has_representative, default: false
      t.boolean :has_dpo, default: false
      t.boolean :has_joint_controller, default: false

      # Purpose & surveillance
      t.boolean :surveillance_purpose, default: false

      # Data subjects
      t.jsonb :data_subjects, default: []

      # Sensitive data
      t.boolean :sensitive_data, default: false
      t.jsonb :sensitive_data_types, default: []
      t.integer :sensitive_data_justification

      # Non-sensitive data categories
      t.jsonb :data_categories, default: []

      # Individual rights
      t.jsonb :individual_rights, default: []

      # Security
      t.jsonb :security_measures, default: []

      # Transfers
      t.boolean :inadequate_protection_transfer, default: false
      t.jsonb :transfer_destinations, default: []
      t.integer :transfer_safeguard
      t.integer :transfer_derogation

      # Information
      t.text :information_modalities

      # Risk assessment
      t.boolean :impact_assessment_required, default: false
      t.boolean :profiling, default: false

      # Special cases
      t.boolean :special_case_article, default: false
      t.string :special_case_reference
      t.boolean :prior_authorization, default: false

      t.timestamps
    end

    create_table :processing_purposes do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :purpose_number, null: false
      t.string :purpose_name, null: false
      t.text :purpose_detail
      t.integer :legal_basis, null: false
      t.integer :order_index, null: false

      t.timestamps
    end

    create_table :data_category_details do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :category_type, null: false
      t.text :detail
      t.string :retention_period
      t.integer :retention_period_enum
      t.string :data_source

      t.timestamps
    end

    create_table :access_categories do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :category_number
      t.string :category_name, null: false
      t.text :detail
      t.string :location
      t.integer :order_index

      t.timestamps
    end

    create_table :recipient_categories do |t|
      t.references :processing_activity, null: false, foreign_key: true
      t.integer :recipient_number
      t.string :recipient_name, null: false
      t.text :detail
      t.string :location
      t.integer :order_index

      t.timestamps
    end

    add_index :processing_activities, [:account_id, :created_at]
    add_index :processing_purposes, :order_index
    add_index :access_categories, :order_index
    add_index :recipient_categories, :order_index
  end
end
```

**Step 4: Run migration**

```bash
rails db:migrate
```

**Step 5: Create models**

Create `app/models/processing_activity.rb`:
```ruby
class ProcessingActivity < ApplicationRecord
  belongs_to :account
  belongs_to :response, optional: true

  has_many :processing_purposes, dependent: :destroy
  has_many :data_category_details, dependent: :destroy
  has_many :access_categories, dependent: :destroy
  has_many :recipient_categories, dependent: :destroy

  # Sensitive data justifications
  enum :sensitive_data_justification, {
    explicit_consent: 0,
    vital_interests: 1,
    religious_organization_members: 2,
    manifestly_public_data: 3,
    legal_claims: 4,
    public_interest: 5,
    medical_purposes: 6,
    archiving_research_statistical: 7,
    biometric_workplace_access: 8,
    employment_social_security: 9,
    statistics_institute: 10,
    administrative_judicial_authority: 11,
    public_health_interest: 12
  }, prefix: true

  # Transfer safeguards (Art. 94)
  enum :transfer_safeguard, {
    international_commitment: 0,
    standard_clauses: 1,
    binding_corporate_rules: 2,
    certification: 3,
    code_of_conduct: 4,
    none: 5
  }, prefix: true

  # Transfer derogations (Art. 95)
  enum :transfer_derogation, {
    explicit_consent: 0,
    vital_interests: 1,
    public_interest: 2,
    legal_claims: 3,
    public_register: 4,
    contract_execution: 5,
    third_party_contract: 6,
    none: 7
  }, prefix: true

  validates :name, presence: true

  accepts_nested_attributes_for :processing_purposes, allow_destroy: true
  accepts_nested_attributes_for :data_category_details, allow_destroy: true
  accepts_nested_attributes_for :access_categories, allow_destroy: true
  accepts_nested_attributes_for :recipient_categories, allow_destroy: true
end
```

Create `app/models/processing_purpose.rb`:
```ruby
class ProcessingPurpose < ApplicationRecord
  belongs_to :processing_activity

  enum :legal_basis, {
    consent: 0,
    legal_obligation: 1,
    contract: 2,
    vital_interest: 3,
    public_interest: 4,
    legitimate_interest: 5
  }, prefix: true

  validates :purpose_name, presence: true
  validates :legal_basis, presence: true
  validates :purpose_number, presence: true
  validates :order_index, presence: true

  default_scope { order(order_index: :asc) }
end
```

Create `app/models/data_category_detail.rb`:
```ruby
class DataCategoryDetail < ApplicationRecord
  belongs_to :processing_activity

  enum :category_type, {
    identity_family: 0,
    contact_info: 1,
    education_professional: 2,
    financial: 3,
    official_documents: 4,
    lifestyle_consumption: 5,
    electronic_id: 6,
    criminal_records: 7,
    temporal_info: 8,
    other: 9
  }, prefix: true

  enum :retention_period_enum, {
    one_month: 0,
    two_months: 1,
    three_months: 2,
    six_months: 3,
    one_year: 4,
    two_years: 5,
    three_years: 6,
    five_years: 7,
    ten_years: 8,
    other: 9
  }, prefix: true

  validates :category_type, presence: true
end
```

Create `app/models/access_category.rb`:
```ruby
class AccessCategory < ApplicationRecord
  belongs_to :processing_activity

  validates :category_name, presence: true

  default_scope { order(order_index: :asc) }
end
```

Create `app/models/recipient_category.rb`:
```ruby
class RecipientCategory < ApplicationRecord
  belongs_to :processing_activity

  validates :recipient_name, presence: true

  default_scope { order(order_index: :asc) }
end
```

**Step 6: Update related models**

In `app/models/account.rb`, add:
```ruby
has_many :processing_activities, dependent: :destroy
```

In `app/models/response.rb`, add:
```ruby
has_many :processing_activities, dependent: :nullify
```

**Step 7: Run tests to verify they pass**

```bash
rails test test/models/processing_activity_test.rb
```
Expected: PASS

**Step 8: Commit**

```bash
git add .
git commit -m "feat: create APDP-compliant Article 30 register models"
```

---

## Phase 6: Controllers & Routes

### Task 8: Set Up Questionnaire Routes and Controller

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/questionnaires_controller.rb`
- Create: `app/controllers/responses_controller.rb`
- Create: `app/controllers/answers_controller.rb`
- Create: `test/controllers/questionnaires_controller_test.rb`

**Step 1: Write failing controller test**

Create `test/controllers/questionnaires_controller_test.rb`:
```ruby
require "test_helper"

class QuestionnairesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.account
    sign_in_as @user
  end

  test "should get show" do
    questionnaire = questionnaires(:compliance)
    get questionnaire_url(questionnaire)
    assert_response :success
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/controllers/questionnaires_controller_test.rb
```
Expected: FAIL

**Step 3: Add routes**

In `config/routes.rb`, add inside authenticated scope:
```ruby
resources :questionnaires, only: [:show] do
  resources :responses, only: [:create, :show, :update]
end

resources :responses, only: [:index] do
  resources :answers, only: [:create, :update]
  member do
    post :complete
  end
end
```

**Step 4: Create controllers**

Create `app/controllers/questionnaires_controller.rb`:
```ruby
class QuestionnairesController < ApplicationController
  before_action :set_questionnaire, only: [:show]

  def show
    render inertia: "Questionnaires/Show", props: {
      questionnaire: questionnaire_props(@questionnaire)
    }
  end

  private

  def set_questionnaire
    @questionnaire = Questionnaire.published.find(params[:id])
  end

  def questionnaire_props(questionnaire)
    {
      id: questionnaire.id,
      title: questionnaire.title,
      description: questionnaire.description,
      sections: questionnaire.sections.map { |s| section_props(s) }
    }
  end

  def section_props(section)
    {
      id: section.id,
      title: section.title,
      description: section.description,
      order_index: section.order_index,
      questions: section.questions.map { |q| question_props(q) }
    }
  end

  def question_props(question)
    {
      id: question.id,
      question_text: question.question_text,
      question_type: question.question_type,
      help_text: question.help_text,
      is_required: question.is_required,
      weight: question.weight,
      answer_choices: question.answer_choices.map { |ac| answer_choice_props(ac) }
    }
  end

  def answer_choice_props(choice)
    {
      id: choice.id,
      choice_text: choice.choice_text,
      score: choice.score
    }
  end
end
```

Create `app/controllers/responses_controller.rb`:
```ruby
class ResponsesController < ApplicationController
  before_action :set_response, only: [:show, :update, :complete]

  def index
    responses = Current.account.responses
      .includes(:questionnaire, :compliance_assessment)
      .order(created_at: :desc)

    render inertia: "Responses/Index", props: {
      responses: responses.map { |r| response_props(r) }
    }
  end

  def create
    questionnaire = Questionnaire.published.find(params[:questionnaire_id])

    response = Current.account.responses.build(
      questionnaire: questionnaire,
      respondent: Current.user,
      status: :in_progress
    )

    if response.save
      redirect_to response_path(response)
    else
      redirect_back fallback_location: root_path, alert: response.errors.full_messages.join(", ")
    end
  end

  def show
    render inertia: "Responses/Show", props: {
      response: response_props(@response),
      questionnaire: questionnaire_props(@response.questionnaire)
    }
  end

  def update
    if @response.update(response_params)
      head :no_content
    else
      render json: { errors: @response.errors }, status: :unprocessable_entity
    end
  end

  def complete
    @response.update!(
      status: :completed,
      completed_at: Time.current
    )

    # Trigger compliance assessment calculation
    CalculateComplianceScoreJob.perform_later(@response.id)

    redirect_to dashboard_path, notice: "Évaluation complétée avec succès"
  end

  private

  def set_response
    @response = Current.account.responses.find(params[:id])
  end

  def response_params
    params.require(:response).permit(:status)
  end

  def response_props(response)
    {
      id: response.id,
      status: response.status,
      started_at: response.started_at,
      completed_at: response.completed_at,
      questionnaire: {
        id: response.questionnaire.id,
        title: response.questionnaire.title
      },
      compliance_assessment: response.compliance_assessment ? {
        overall_score: response.compliance_assessment.overall_score,
        risk_level: response.compliance_assessment.risk_level
      } : nil
    }
  end

  def questionnaire_props(questionnaire)
    # Reuse from QuestionnairesController
    QuestionnairesController.new.send(:questionnaire_props, questionnaire)
  end
end
```

Create `app/controllers/answers_controller.rb`:
```ruby
class AnswersController < ApplicationController
  before_action :set_response

  def create
    answer = @response.answers.build(answer_params)

    if answer.save
      head :no_content
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  def update
    answer = @response.answers.find(params[:id])

    if answer.update(answer_params)
      head :no_content
    else
      render json: { errors: answer.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_response
    @response = Current.account.responses.find(params[:response_id])
  end

  def answer_params
    params.require(:answer).permit(:question_id, answer_value: {})
  end
end
```

**Step 5: Run tests to verify they pass**

```bash
rails test test/controllers/questionnaires_controller_test.rb
```
Expected: PASS

**Step 6: Commit**

```bash
git add .
git commit -m "feat: add questionnaire, response, and answer controllers"
```

---

### Task 9: Create Dashboard Controller

**Files:**
- Modify: `config/routes.rb`
- Create: `app/controllers/dashboard_controller.rb`
- Create: `test/controllers/dashboard_controller_test.rb`

**Step 1: Write failing test**

Create `test/controllers/dashboard_controller_test.rb`:
```ruby
require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "should get show" do
    get dashboard_url
    assert_response :success
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/controllers/dashboard_controller_test.rb
```
Expected: FAIL

**Step 3: Add route**

In `config/routes.rb`:
```ruby
get "dashboard", to: "dashboard#show"
```

**Step 4: Create controller**

Create `app/controllers/dashboard_controller.rb`:
```ruby
class DashboardController < ApplicationController
  def show
    latest_response = Current.account.responses
      .includes(:compliance_assessment, :documents)
      .completed
      .order(created_at: :desc)
      .first

    render inertia: "Dashboard/Show", props: {
      latest_assessment: latest_response&.compliance_assessment ? assessment_props(latest_response.compliance_assessment) : nil,
      documents: latest_response ? latest_response.documents.ready.map { |d| document_props(d) } : [],
      responses: Current.account.responses.order(created_at: :desc).limit(5).map { |r| response_summary_props(r) }
    }
  end

  private

  def assessment_props(assessment)
    {
      overall_score: assessment.overall_score.round(1),
      max_possible_score: assessment.max_possible_score,
      risk_level: assessment.risk_level,
      created_at: assessment.created_at,
      compliance_area_scores: assessment.compliance_area_scores.includes(:compliance_area).map do |cas|
        {
          area_name: cas.compliance_area.name,
          area_code: cas.compliance_area.code,
          score: cas.score.round(1),
          max_score: cas.max_score,
          percentage: cas.percentage
        }
      end
    }
  end

  def document_props(document)
    {
      id: document.id,
      title: document.title,
      document_type: document.document_type,
      generated_at: document.generated_at,
      download_url: rails_blob_path(document.pdf_file, disposition: "attachment")
    }
  end

  def response_summary_props(response)
    {
      id: response.id,
      created_at: response.created_at,
      completed_at: response.completed_at,
      status: response.status
    }
  end
end
```

**Step 5: Run test to verify it passes**

```bash
rails test test/controllers/dashboard_controller_test.rb
```
Expected: PASS

**Step 6: Commit**

```bash
git add .
git commit -m "feat: add dashboard controller"
```

---

## Phase 7: Background Jobs

### Task 10: Create Compliance Scoring Job

**Files:**
- Create: `app/jobs/calculate_compliance_score_job.rb`
- Create: `app/services/compliance_scorer.rb`
- Create: `test/jobs/calculate_compliance_score_job_test.rb`
- Create: `test/services/compliance_scorer_test.rb`

**Step 1: Write failing job test**

Create `test/jobs/calculate_compliance_score_job_test.rb`:
```ruby
require "test_helper"

class CalculateComplianceScoreJobTest < ActiveJob::TestCase
  test "should calculate compliance score for response" do
    response = responses(:one)

    assert_enqueued_with(job: CalculateComplianceScoreJob, args: [response.id]) do
      CalculateComplianceScoreJob.perform_later(response.id)
    end
  end
end
```

**Step 2: Write failing service test**

Create `test/services/compliance_scorer_test.rb`:
```ruby
require "test_helper"

class ComplianceScorerTest < ActiveSupport::TestCase
  test "should calculate overall score from answers" do
    response = responses(:completed_response)
    scorer = ComplianceScorer.new(response)

    assessment = scorer.calculate

    assert assessment.persisted?
    assert assessment.overall_score > 0
    assert_not_nil assessment.risk_level
  end

  test "should calculate compliance area scores" do
    response = responses(:completed_response)
    scorer = ComplianceScorer.new(response)

    assessment = scorer.calculate

    assert assessment.compliance_area_scores.any?
  end
end
```

**Step 3: Run tests to verify they fail**

```bash
rails test test/jobs/calculate_compliance_score_job_test.rb
rails test test/services/compliance_scorer_test.rb
```
Expected: FAIL

**Step 4: Create compliance scorer service**

Create `app/services/compliance_scorer.rb`:
```ruby
class ComplianceScorer
  def initialize(response)
    @response = response
    @account = response.account
  end

  def calculate
    assessment = @response.build_compliance_assessment(
      account: @account,
      status: :draft
    )

    # Calculate overall score
    total_score = 0
    max_score = 0

    @response.answers.includes(question: :answer_choices).each do |answer|
      question = answer.question
      next unless question.weight.present?

      question_score = calculate_question_score(answer, question)
      max_question_score = question.weight * 100

      total_score += question_score
      max_score += max_question_score
    end

    assessment.overall_score = total_score
    assessment.max_possible_score = max_score
    assessment.status = :completed
    assessment.save!

    # Calculate area scores
    calculate_area_scores(assessment)

    assessment
  end

  private

  def calculate_question_score(answer, question)
    case question.question_type
    when "yes_no", "single_choice"
      choice = question.answer_choices.find_by(id: answer.answer_value["choice_id"])
      choice ? (choice.score * question.weight) : 0
    when "multiple_choice"
      choice_ids = answer.answer_value["choice_ids"] || []
      choices = question.answer_choices.where(id: choice_ids)
      avg_score = choices.any? ? (choices.sum(&:score) / choices.count) : 0
      avg_score * question.weight
    when "rating_scale"
      rating = answer.answer_value["rating"].to_f
      max_rating = question.settings["max_rating"] || 5
      (rating / max_rating * 100) * question.weight
    else
      0
    end
  end

  def calculate_area_scores(assessment)
    # For MVP, we'll create a simplified version
    # Group questions by section and calculate scores per section
    # This maps to compliance areas

    compliance_areas = ComplianceArea.all

    compliance_areas.each do |area|
      # Find questions related to this area (by section or tags)
      # Calculate score for this area
      # For now, simplified: equal distribution

      area_score = assessment.overall_score / compliance_areas.count
      area_max_score = assessment.max_possible_score / compliance_areas.count

      assessment.compliance_area_scores.create!(
        compliance_area: area,
        score: area_score,
        max_score: area_max_score
      )
    end
  end
end
```

**Step 5: Create job**

Create `app/jobs/calculate_compliance_score_job.rb`:
```ruby
class CalculateComplianceScoreJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = Response.find(response_id)
    scorer = ComplianceScorer.new(response)
    scorer.calculate
  end
end
```

**Step 6: Run tests to verify they pass**

```bash
rails test test/jobs/calculate_compliance_score_job_test.rb
rails test test/services/compliance_scorer_test.rb
```
Expected: PASS

**Step 7: Commit**

```bash
git add .
git commit -m "feat: add compliance scoring service and job"
```

---

### Task 11: Create Document Generation Job

**Files:**
- Create: `app/jobs/generate_documents_job.rb`
- Create: `app/services/document_generator.rb`
- Create: `app/services/pdf_renderer.rb`
- Create: `test/jobs/generate_documents_job_test.rb`

**Step 1: Write failing test**

Create `test/jobs/generate_documents_job_test.rb`:
```ruby
require "test_helper"

class GenerateDocumentsJobTest < ActiveJob::TestCase
  test "should generate all documents for response" do
    response = responses(:completed_response)

    assert_enqueued_with(job: GenerateDocumentsJob, args: [response.id]) do
      GenerateDocumentsJob.perform_later(response.id)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
rails test test/jobs/generate_documents_job_test.rb
```
Expected: FAIL

**Step 3: Create document generator service**

Create `app/services/document_generator.rb`:
```ruby
class DocumentGenerator
  DOCUMENT_TYPES = [:privacy_policy, :processing_register, :consent_form, :employee_notice]

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
      document.update!(status: :failed)
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
      hash["question_#{question.id}"] = answer.answer_value
    end
  end

  def build_processing_activities_context
    @account.processing_activities.map do |activity|
      {
        "name" => activity.name,
        "purposes" => activity.processing_purposes.map(&:purpose_name),
        "data_categories" => activity.data_category_details.map(&:detail),
        "retention_periods" => activity.data_category_details.map(&:retention_period)
      }
    end
  end
end
```

Create `app/services/pdf_renderer.rb`:
```ruby
require "prawn"
require "prawn/table"

class PdfRenderer
  def render(html_content, document_type)
    Prawn::Document.new do |pdf|
      pdf.font "Helvetica"

      # Add header
      pdf.text "Monaco RGPD", size: 24, style: :bold
      pdf.move_down 20

      # For MVP, we'll render simplified PDF
      # In production, you'd parse HTML and render properly
      pdf.text html_content, size: 11

      # Add footer with page numbers
      pdf.number_pages "<page> / <total>", at: [pdf.bounds.right - 50, 0], align: :right
    end.render
  end
end
```

**Step 4: Create job**

Create `app/jobs/generate_documents_job.rb`:
```ruby
class GenerateDocumentsJob < ApplicationJob
  queue_as :default

  def perform(response_id)
    response = Response.find(response_id)
    generator = DocumentGenerator.new(response)
    generator.generate_all
  end
end
```

**Step 5: Run tests to verify they pass**

```bash
rails test test/jobs/generate_documents_job_test.rb
```
Expected: PASS

**Step 6: Commit**

```bash
git add .
git commit -m "feat: add document generation service and job"
```

---

## Phase 8: Svelte Frontend Components

### Task 12: Create Questionnaire UI Components

**Files:**
- Create: `app/frontend/pages/Questionnaires/Show.svelte`
- Create: `app/frontend/pages/Responses/Show.svelte`
- Create: `app/frontend/components/QuestionnaireWizard.svelte`
- Create: `app/frontend/components/QuestionCard.svelte`
- Create: `app/frontend/lib/stores/questionnaireStore.js`

**Step 1: Create questionnaire wizard component**

Create `app/frontend/components/QuestionnaireWizard.svelte`:
```svelte
<script>
  import { writable } from 'svelte/store';
  import QuestionCard from './QuestionCard.svelte';

  export let questionnaire;
  export let response;

  let currentQuestionIndex = 0;
  let answers = writable({});

  $: allQuestions = questionnaire.sections.flatMap(s =>
    s.questions.map(q => ({ ...q, sectionTitle: s.title }))
  );
  $: currentQuestion = allQuestions[currentQuestionIndex];
  $: progress = ((currentQuestionIndex + 1) / allQuestions.length * 100).toFixed(0);
  $: isLastQuestion = currentQuestionIndex === allQuestions.length - 1;

  async function handleAnswer(questionId, answerValue) {
    answers.update(a => ({ ...a, [questionId]: answerValue }));

    // Save answer to backend
    await fetch(`/responses/${response.id}/answers`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        answer: {
          question_id: questionId,
          answer_value: answerValue
        }
      })
    });

    // Auto-advance to next question
    if (!isLastQuestion) {
      currentQuestionIndex++;
    }
  }

  function previousQuestion() {
    if (currentQuestionIndex > 0) {
      currentQuestionIndex--;
    }
  }

  async function completeQuestionnaire() {
    await fetch(`/responses/${response.id}/complete`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    });

    window.location.href = '/dashboard';
  }
</script>

<div class="max-w-2xl mx-auto p-6">
  <!-- Progress Bar -->
  <div class="mb-8">
    <div class="flex justify-between items-center mb-2">
      <span class="text-sm text-gray-600">{currentQuestion?.sectionTitle}</span>
      <span class="text-sm font-medium">{progress}%</span>
    </div>
    <div class="w-full bg-gray-200 rounded-full h-2">
      <div
        class="bg-blue-600 h-2 rounded-full transition-all duration-300"
        style="width: {progress}%"
      ></div>
    </div>
  </div>

  <!-- Question Card -->
  {#if currentQuestion}
    <QuestionCard
      question={currentQuestion}
      answer={$answers[currentQuestion.id]}
      on:answer={(e) => handleAnswer(currentQuestion.id, e.detail)}
    />
  {/if}

  <!-- Navigation -->
  <div class="flex justify-between mt-8">
    <button
      on:click={previousQuestion}
      disabled={currentQuestionIndex === 0}
      class="px-4 py-2 text-gray-700 bg-gray-100 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
    >
      ← Précédent
    </button>

    {#if isLastQuestion}
      <button
        on:click={completeQuestionnaire}
        class="px-6 py-2 text-white bg-green-600 rounded hover:bg-green-700"
      >
        Terminer l'évaluation
      </button>
    {:else}
      <button
        disabled={!$answers[currentQuestion.id]}
        class="px-4 py-2 text-white bg-blue-600 rounded hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        Suivant →
      </button>
    {/if}
  </div>
</div>
```

**Step 2: Create question card component**

Create `app/frontend/components/QuestionCard.svelte`:
```svelte
<script>
  import { createEventDispatcher } from 'svelte';

  export let question;
  export let answer = null;

  const dispatch = createEventDispatcher();

  let selectedValue = answer || {};

  function handleYesNo(value) {
    selectedValue = { value };
    dispatch('answer', selectedValue);
  }

  function handleSingleChoice(choiceId) {
    selectedValue = { choice_id: choiceId };
    dispatch('answer', selectedValue);
  }

  function handleMultipleChoice(choiceId, checked) {
    const choiceIds = selectedValue.choice_ids || [];
    if (checked) {
      selectedValue = { choice_ids: [...choiceIds, choiceId] };
    } else {
      selectedValue = { choice_ids: choiceIds.filter(id => id !== choiceId) };
    }
    dispatch('answer', selectedValue);
  }

  function handleText(value) {
    selectedValue = { text: value };
    dispatch('answer', selectedValue);
  }
</script>

<div class="bg-white rounded-lg shadow-lg p-8">
  <h2 class="text-2xl font-bold mb-4">{question.question_text}</h2>

  {#if question.help_text}
    <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6">
      <p class="text-sm text-blue-700">{question.help_text}</p>
    </div>
  {/if}

  <div class="space-y-4">
    {#if question.question_type === 'yes_no'}
      <div class="flex space-x-4">
        <button
          on:click={() => handleYesNo('Oui')}
          class="flex-1 py-3 px-6 rounded-lg border-2 transition-all {selectedValue.value === 'Oui' ? 'border-green-500 bg-green-50 text-green-700' : 'border-gray-300 hover:border-gray-400'}"
        >
          Oui
        </button>
        <button
          on:click={() => handleYesNo('Non')}
          class="flex-1 py-3 px-6 rounded-lg border-2 transition-all {selectedValue.value === 'Non' ? 'border-red-500 bg-red-50 text-red-700' : 'border-gray-300 hover:border-gray-400'}"
        >
          Non
        </button>
      </div>

    {:else if question.question_type === 'single_choice'}
      <div class="space-y-2">
        {#each question.answer_choices as choice}
          <button
            on:click={() => handleSingleChoice(choice.id)}
            class="w-full text-left py-3 px-4 rounded-lg border-2 transition-all {selectedValue.choice_id === choice.id ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'}"
          >
            {choice.choice_text}
          </button>
        {/each}
      </div>

    {:else if question.question_type === 'multiple_choice'}
      <div class="space-y-2">
        {#each question.answer_choices as choice}
          <label class="flex items-center py-3 px-4 rounded-lg border-2 border-gray-300 hover:border-gray-400 cursor-pointer">
            <input
              type="checkbox"
              checked={selectedValue.choice_ids?.includes(choice.id)}
              on:change={(e) => handleMultipleChoice(choice.id, e.target.checked)}
              class="mr-3 h-5 w-5 text-blue-600"
            />
            <span>{choice.choice_text}</span>
          </label>
        {/each}
      </div>

    {:else if question.question_type === 'text_short'}
      <input
        type="text"
        value={selectedValue.text || ''}
        on:input={(e) => handleText(e.target.value)}
        class="w-full py-3 px-4 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none"
        placeholder="Votre réponse..."
      />

    {:else if question.question_type === 'text_long'}
      <textarea
        value={selectedValue.text || ''}
        on:input={(e) => handleText(e.target.value)}
        rows="5"
        class="w-full py-3 px-4 border-2 border-gray-300 rounded-lg focus:border-blue-500 focus:outline-none"
        placeholder="Votre réponse..."
      ></textarea>
    {/if}
  </div>
</div>
```

**Step 3: Create response show page**

Create `app/frontend/pages/Responses/Show.svelte`:
```svelte
<script>
  import QuestionnaireWizard from '../../components/QuestionnaireWizard.svelte';

  export let response;
  export let questionnaire;
</script>

<div class="min-h-screen bg-gray-50 py-12">
  <QuestionnaireWizard {questionnaire} {response} />
</div>
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: create questionnaire UI components"
```

---

### Task 13: Create Dashboard UI

**Files:**
- Create: `app/frontend/pages/Dashboard/Show.svelte`
- Create: `app/frontend/components/ComplianceScoreCard.svelte`
- Create: `app/frontend/components/DocumentList.svelte`

**Step 1: Create dashboard page**

Create `app/frontend/pages/Dashboard/Show.svelte`:
```svelte
<script>
  import ComplianceScoreCard from '../../components/ComplianceScoreCard.svelte';
  import DocumentList from '../../components/DocumentList.svelte';

  export let latest_assessment;
  export let documents;
  export let responses;

  function getRiskLevelColor(riskLevel) {
    const colors = {
      'compliant': 'green',
      'attention_required': 'yellow',
      'non_compliant': 'red'
    };
    return colors[riskLevel] || 'gray';
  }

  function getRiskLevelText(riskLevel) {
    const texts = {
      'compliant': 'Conforme',
      'attention_required': 'Attention requise',
      'non_compliant': 'Non-conforme'
    };
    return texts[riskLevel] || 'Inconnu';
  }
</script>

<div class="min-h-screen bg-gray-50">
  <div class="max-w-7xl mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-8">Tableau de bord de conformité</h1>

    {#if latest_assessment}
      <!-- Score Card -->
      <ComplianceScoreCard assessment={latest_assessment} />

      <!-- Compliance Areas Breakdown -->
      <div class="bg-white rounded-lg shadow-md p-6 mb-8">
        <h2 class="text-xl font-bold mb-4">Conformité par domaine</h2>
        <div class="space-y-4">
          {#each latest_assessment.compliance_area_scores as area}
            <div>
              <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-medium">{area.area_name}</span>
                <span class="text-sm font-bold">{area.percentage}%</span>
              </div>
              <div class="w-full bg-gray-200 rounded-full h-3">
                <div
                  class="h-3 rounded-full {area.percentage >= 85 ? 'bg-green-500' : area.percentage >= 60 ? 'bg-yellow-500' : 'bg-red-500'}"
                  style="width: {area.percentage}%"
                ></div>
              </div>
            </div>
          {/each}
        </div>
      </div>

      <!-- Documents -->
      {#if documents.length > 0}
        <DocumentList {documents} />
      {/if}

    {:else}
      <!-- Empty State -->
      <div class="bg-white rounded-lg shadow-md p-12 text-center">
        <h2 class="text-2xl font-bold mb-4">Bienvenue sur Monaco RGPD! 👋</h2>
        <p class="text-gray-600 mb-6">Complétez votre évaluation pour obtenir:</p>
        <ul class="text-left max-w-md mx-auto mb-8 space-y-2">
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            Votre score de conformité
          </li>
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            4 documents essentiels
          </li>
          <li class="flex items-center">
            <span class="text-green-500 mr-2">✓</span>
            Votre registre Article 30
          </li>
        </ul>
        <a
          href="/questionnaires/1"
          class="inline-block px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
        >
          🚀 Commencer l'évaluation
        </a>
        <p class="text-sm text-gray-500 mt-4">⏱️ Temps estimé: 15-20 minutes</p>
      </div>
    {/if}
  </div>
</div>
```

**Step 2: Create compliance score card component**

Create `app/frontend/components/ComplianceScoreCard.svelte`:
```svelte
<script>
  export let assessment;

  $: percentage = (assessment.overall_score / assessment.max_possible_score * 100).toFixed(0);
  $: riskLevelColor = {
    'compliant': 'green',
    'attention_required': 'yellow',
    'non_compliant': 'red'
  }[assessment.risk_level];

  $: riskLevelText = {
    'compliant': 'Conforme',
    'attention_required': 'Attention requise',
    'non_compliant': 'Non-conforme'
  }[assessment.risk_level];
</script>

<div class="bg-white rounded-lg shadow-md p-8 mb-8">
  <div class="flex items-center justify-between">
    <div class="flex-1">
      <h2 class="text-lg font-medium text-gray-600 mb-2">Score global</h2>
      <div class="flex items-baseline space-x-3">
        <span class="text-5xl font-bold text-{riskLevelColor}-600">{percentage}%</span>
        <span class="text-xl text-gray-500">/ 100%</span>
      </div>
      <p class="mt-3 text-lg">
        Statut: <span class="font-bold text-{riskLevelColor}-600">{riskLevelText}</span>
      </p>
      <p class="mt-2 text-sm text-gray-500">
        Dernière évaluation: {new Date(assessment.created_at).toLocaleDateString('fr-FR')}
      </p>
    </div>

    <div class="flex space-x-3">
      <a
        href="/responses"
        class="px-6 py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 font-medium"
      >
        📊 Voir les détails
      </a>
      <a
        href="/questionnaires/1/responses"
        class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium"
      >
        🔄 Nouvelle évaluation
      </a>
    </div>
  </div>
</div>
```

**Step 3: Create document list component**

Create `app/frontend/components/DocumentList.svelte`:
```svelte
<script>
  export let documents;

  const documentTypeIcons = {
    privacy_policy: '📄',
    processing_register: '📋',
    consent_form: '✍️',
    employee_notice: '👥'
  };

  const documentTypeNames = {
    privacy_policy: 'Politique de confidentialité',
    processing_register: 'Registre des traitements',
    consent_form: 'Formulaires de consentement',
    employee_notice: 'Notice employés'
  };
</script>

<div class="bg-white rounded-lg shadow-md p-6">
  <h2 class="text-xl font-bold mb-4">📄 Vos documents</h2>
  <div class="space-y-3">
    {#each documents as document}
      <div class="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50">
        <div class="flex items-center space-x-3">
          <span class="text-2xl">{documentTypeIcons[document.document_type]}</span>
          <div>
            <p class="font-medium">{documentTypeNames[document.document_type]}</p>
            <p class="text-sm text-gray-500">
              Généré le {new Date(document.generated_at).toLocaleDateString('fr-FR')}
            </p>
          </div>
        </div>
        <a
          href={document.download_url}
          class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm font-medium"
        >
          ⬇️ Télécharger
        </a>
      </div>
    {/each}
  </div>

  <button
    class="mt-6 w-full py-3 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 font-medium"
  >
    🔄 Régénérer tous les documents
  </button>
</div>
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: create dashboard UI components"
```

---

## Phase 9: Seed Data

### Task 14: Create Compliance Areas Seed Data

**Files:**
- Create: `db/seeds/compliance_areas.rb`
- Modify: `db/seeds.rb`

**Step 1: Create compliance areas seed**

Create `db/seeds/compliance_areas.rb`:
```ruby
# Monaco RGPD Compliance Areas based on Loi n° 1.565

compliance_areas_data = [
  {
    name: "Licéité du traitement",
    code: "lawfulness",
    description: "Bases juridiques et licéité des traitements de données personnelles"
  },
  {
    name: "Information des personnes",
    code: "transparency",
    description: "Transparence et information des personnes concernées"
  },
  {
    name: "Droits des personnes",
    code: "rights",
    description: "Respect des droits d'accès, rectification, effacement, opposition, etc."
  },
  {
    name: "Sécurité des données",
    code: "security",
    description: "Mesures techniques et organisationnelles de sécurité"
  },
  {
    name: "Transferts de données",
    code: "transfers",
    description: "Transferts de données vers des pays tiers"
  }
]

compliance_areas_data.each do |area_data|
  ComplianceArea.find_or_create_by!(code: area_data[:code]) do |area|
    area.name = area_data[:name]
    area.description = area_data[:description]
  end
end

puts "✓ Created #{ComplianceArea.count} compliance areas"
```

**Step 2: Update main seeds file**

In `db/seeds.rb`, add:
```ruby
# Load compliance areas
require_relative "seeds/compliance_areas"

puts "Seeds completed successfully!"
```

**Step 3: Run seeds**

```bash
rails db:seed
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add compliance areas seed data"
```

---

### Task 15: Create Master Questionnaire Seed (Simplified MVP Version)

**Files:**
- Create: `db/seeds/master_questionnaire.rb`
- Modify: `db/seeds.rb`

**Step 1: Create simplified questionnaire seed**

Create `db/seeds/master_questionnaire.rb`:
```ruby
# Simplified Monaco RGPD Master Questionnaire for MVP
# This is a starter questionnaire - your lawyer will refine the questions

questionnaire = Questionnaire.find_or_create_by!(title: "Évaluation RGPD Monaco") do |q|
  q.description = "Évaluation de conformité à la Loi n° 1.565"
  q.category = "compliance_assessment"
  q.status = :published
end

# Section 1: Informations générales
section1 = questionnaire.sections.find_or_create_by!(order_index: 1) do |s|
  s.title = "Informations générales"
  s.description = "Informations de base sur votre organisation"
end

section1.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Votre organisation est-elle basée à Monaco?"
  q.question_type = :yes_no
  q.help_text = "Cette plateforme est actuellement réservée aux entités basées à Monaco."
  q.is_required = true
  q.weight = 0 # Not scored, just a gate
end

section1.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Quel est le type de votre entité?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Entreprise")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Association")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "ONG")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "Administration publique")
end

section1.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Combien d'employés/collaborateurs compte votre organisation?"
  q.question_type = :single_choice
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "0 (travailleur indépendant)")
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "1-5")
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "6-10")
  q.answer_choices.find_or_create_by!(order_index: 4, choice_text: "11-50")
  q.answer_choices.find_or_create_by!(order_index: 5, choice_text: "50+")
end

# Section 2: Collecte et traitement des données
section2 = questionnaire.sections.find_or_create_by!(order_index: 2) do |s|
  s.title = "Collecte et traitement des données"
  s.description = "Quelles données collectez-vous et comment?"
end

section2.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Collectez-vous des données personnelles de clients?"
  q.question_type = :yes_no
  q.help_text = "Données personnelles: nom, email, adresse, téléphone, etc."
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(choice_text: "Non", score: 100)
end

section2.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Avez-vous une politique de confidentialité publiée et à jour?"
  q.question_type = :single_choice
  q.help_text = "Article 13, Loi n° 1.565"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, publiée et à jour", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Oui, mais obsolète", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

section2.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Disposez-vous d'un registre des traitements (Article 30)?"
  q.question_type = :single_choice
  q.help_text = "Le registre des traitements est obligatoire pour la plupart des organisations"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, complet et à jour", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Oui, mais incomplet", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

# Section 3: Droits des personnes
section3 = questionnaire.sections.find_or_create_by!(order_index: 3) do |s|
  s.title = "Droits des personnes"
  s.description = "Comment respectez-vous les droits des personnes concernées?"
end

section3.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Avez-vous une procédure pour traiter les demandes d'accès aux données?"
  q.question_type = :yes_no
  q.help_text = "Article 15, Loi n° 1.565 - Droit d'accès"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(choice_text: "Non", score: 0)
end

section3.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Les personnes peuvent-elles facilement exercer leurs droits (rectification, effacement, opposition)?"
  q.question_type = :single_choice
  q.help_text = "Articles 16-21, Loi n° 1.565"
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, procédure claire", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

# Section 4: Sécurité des données
section4 = questionnaire.sections.find_or_create_by!(order_index: 4) do |s|
  s.title = "Sécurité des données"
  s.description = "Quelles mesures de sécurité avez-vous mises en place?"
end

section4.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Utilisez-vous le chiffrement pour protéger les données sensibles?"
  q.question_type = :single_choice
  q.help_text = "Article 32, Loi n° 1.565 - Sécurité des traitements"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, systématiquement", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

section4.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Effectuez-vous des sauvegardes régulières des données?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(choice_text: "Non", score: 0)
end

section4.questions.find_or_create_by!(order_index: 3) do |q|
  q.question_text = "Limitez-vous l'accès aux données personnelles aux seules personnes autorisées?"
  q.question_type = :yes_no
  q.is_required = true
  q.weight = 2
end.tap do |q|
  q.answer_choices.find_or_create_by!(choice_text: "Oui", score: 100)
  q.answer_choices.find_or_create_by!(choice_text: "Non", score: 0)
end

# Section 5: Relations avec les tiers
section5 = questionnaire.sections.find_or_create_by!(order_index: 5) do |s|
  s.title = "Relations avec les tiers"
  s.description = "Comment gérez-vous les relations avec vos sous-traitants?"
end

section5.questions.find_or_create_by!(order_index: 1) do |q|
  q.question_text = "Faites-vous appel à des sous-traitants qui traitent des données personnelles?"
  q.question_type = :yes_no
  q.help_text = "Ex: hébergeur, service de paiement, comptable"
  q.is_required = true
  q.weight = 0
end.tap do |q|
  q.answer_choices.find_or_create_by!(choice_text: "Oui", score: 0)
  q.answer_choices.find_or_create_by!(choice_text: "Non", score: 100)
end

section5.questions.find_or_create_by!(order_index: 2) do |q|
  q.question_text = "Avez-vous signé des accords de sous-traitance (DPA) avec vos prestataires?"
  q.question_type = :single_choice
  q.help_text = "Article 28, Loi n° 1.565"
  q.is_required = true
  q.weight = 3
end.tap do |q|
  q.answer_choices.find_or_create_by!(order_index: 1, choice_text: "Oui, avec tous", score: 100)
  q.answer_choices.find_or_create_by!(order_index: 2, choice_text: "Partiellement", score: 50)
  q.answer_choices.find_or_create_by!(order_index: 3, choice_text: "Non", score: 0)
end

puts "✓ Created master questionnaire with #{questionnaire.sections.count} sections and #{questionnaire.questions.count} questions"
```

**Step 2: Update main seeds file**

In `db/seeds.rb`, add:
```ruby
# Load master questionnaire
require_relative "seeds/master_questionnaire"
```

**Step 3: Run seeds**

```bash
rails db:seed
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add simplified master questionnaire seed"
```

---

## Phase 10: Document Templates

### Task 16: Create Initial Document Templates

**Files:**
- Create: `db/seeds/document_templates.rb`
- Modify: `db/seeds.rb`

**Step 1: Create document templates seed**

Create `db/seeds/document_templates.rb`:
```ruby
# Initial document templates for Monaco RGPD
# These are simplified starter templates - your lawyer will refine them

templates_data = [
  {
    document_type: :privacy_policy,
    title: "Politique de confidentialité",
    content: <<~LIQUID
      # POLITIQUE DE CONFIDENTIALITÉ

      ## {{ account.name }}

      **Dernière mise à jour:** {{ "now" | date: "%d/%m/%Y" }}

      ### 1. Responsable du traitement

      {{ account.name }}, {{ account.entity_type }}, situé à Monaco.

      ### 2. Données collectées

      Nous collectons et traitons les catégories de données personnelles suivantes :

      {% for activity in processing_activities %}
      - {{ activity.name }}
      {% endfor %}

      ### 3. Bases juridiques

      Les traitements de données personnelles sont fondés sur les bases juridiques prévues par la Loi n° 1.565.

      ### 4. Vos droits

      Conformément aux articles 15 à 22 de la Loi n° 1.565, vous disposez des droits suivants :
      - Droit d'accès à vos données
      - Droit de rectification
      - Droit à l'effacement
      - Droit d'opposition
      - Droit à la limitation du traitement
      - Droit à la portabilité

      Pour exercer vos droits, contactez-nous à : [adresse email]

      ### 5. Conservation des données

      Vos données sont conservées pendant les durées suivantes :
      {% for activity in processing_activities %}
      - {{ activity.name }}: {{ activity.retention_periods | join: ", " }}
      {% endfor %}

      ### 6. Sécurité

      Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données.

      ### 7. Contact

      Pour toute question concernant cette politique, contactez-nous à : [coordonnées]

      ---

      Document généré par Monaco RGPD - Conforme à la Loi n° 1.565
    LIQUID
  },
  {
    document_type: :processing_register,
    title: "Registre des traitements (Article 30)",
    content: <<~LIQUID
      # REGISTRE DES TRAITEMENTS
      # Article 30 - Loi n° 1.565

      **Organisation:** {{ account.name }}
      **Type:** {{ account.entity_type }}
      **Date:** {{ "now" | date: "%d/%m/%Y" }}

      ---

      {% for activity in processing_activities %}
      ## Activité {{ forloop.index }}: {{ activity.name }}

      **Finalités:**
      {% for purpose in activity.purposes %}
      - {{ purpose }}
      {% endfor %}

      **Catégories de données:**
      {% for category in activity.data_categories %}
      - {{ category }}
      {% endfor %}

      **Durées de conservation:**
      {% for period in activity.retention_periods %}
      - {{ period }}
      {% endfor %}

      ---

      {% endfor %}

      Document généré par Monaco RGPD - Conforme à la Loi n° 1.565
    LIQUID
  },
  {
    document_type: :consent_form,
    title: "Formulaire de consentement",
    content: <<~LIQUID
      # FORMULAIRE DE CONSENTEMENT

      **{{ account.name }}**

      Nous collectons vos données personnelles afin de [finalité].

      Conformément à la Loi n° 1.565, nous vous informons que :

      - Vos données seront utilisées pour [finalités]
      - Elles seront conservées pendant [durée]
      - Vous pouvez retirer votre consentement à tout moment
      - Vous disposez d'un droit d'accès, de rectification et d'effacement

      **Consentement:**

      ☐ J'accepte que {{ account.name }} collecte et traite mes données personnelles conformément à cette politique.

      Date: ________________
      Signature: ________________

      ---

      Document généré par Monaco RGPD
    LIQUID
  },
  {
    document_type: :employee_notice,
    title: "Notice d'information employés",
    content: <<~LIQUID
      # NOTICE D'INFORMATION - EMPLOYÉS

      **{{ account.name }}**

      Conformément à la Loi n° 1.565, nous vous informons des traitements de données personnelles vous concernant.

      ### Données collectées

      Dans le cadre de votre emploi, nous collectons et traitons les données suivantes :
      - Identité et coordonnées
      - Données relatives au contrat de travail
      - Données de paie
      - Formation et compétences

      ### Finalités

      Ces données sont traitées pour :
      - Gestion administrative du personnel
      - Gestion de la paie
      - Gestion des formations

      ### Vos droits

      Vous disposez des droits suivants :
      - Droit d'accès
      - Droit de rectification
      - Droit à l'effacement
      - Droit d'opposition
      - Droit à la limitation

      Pour exercer vos droits : [coordonnées RH]

      ### Conservation

      Vos données sont conservées pendant la durée de votre emploi et conformément aux obligations légales de conservation.

      ---

      Document généré par Monaco RGPD
    LIQUID
  }
]

templates_data.each do |template_data|
  DocumentTemplate.find_or_create_by!(document_type: template_data[:document_type]) do |template|
    template.title = template_data[:title]
    template.content = template_data[:content]
    template.version = 1
    template.is_active = true
  end
end

puts "✓ Created #{DocumentTemplate.count} document templates"
```

**Step 2: Update main seeds file**

In `db/seeds.rb`, add:
```ruby
# Load document templates
require_relative "seeds/document_templates"
```

**Step 3: Run seeds**

```bash
rails db:seed
```

**Step 4: Commit**

```bash
git add .
git commit -m "feat: add initial document templates"
```

---

## Phase 11: Testing & Polish

### Task 17: Add Integration Tests

**Files:**
- Create: `test/integration/compliance_assessment_flow_test.rb`

**Step 1: Write integration test**

Create `test/integration/compliance_assessment_flow_test.rb`:
```ruby
require "test_helper"

class ComplianceAssessmentFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = @user.account
    sign_in_as @user
  end

  test "complete compliance assessment flow" do
    # 1. Start questionnaire
    questionnaire = questionnaires(:compliance)

    post questionnaire_responses_path(questionnaire)
    assert_response :redirect

    response = @account.responses.last
    assert_equal :in_progress, response.status

    # 2. Answer questions
    question = questions(:first)

    post response_answers_path(response), params: {
      answer: {
        question_id: question.id,
        answer_value: { choice_id: answer_choices(:yes).id }
      }
    }
    assert_response :success

    assert_equal 1, response.answers.count

    # 3. Complete questionnaire
    post complete_response_path(response)
    assert_response :redirect

    response.reload
    assert_equal :completed, response.status
    assert_not_nil response.completed_at

    # 4. Verify compliance assessment job enqueued
    assert_enqueued_jobs 1, only: CalculateComplianceScoreJob
  end
end
```

**Step 2: Run test**

```bash
rails test test/integration/compliance_assessment_flow_test.rb
```

**Step 3: Commit**

```bash
git add .
git commit -m "test: add compliance assessment integration test"
```

---

### Task 18: Final Setup Documentation

**Files:**
- Create: `docs/SETUP.md`
- Create: `docs/ARCHITECTURE.md`

**Step 1: Create setup documentation**

Create `docs/SETUP.md`:
```markdown
# Monaco RGPD - Setup Guide

## Prerequisites

- Ruby 3.3+
- PostgreSQL 18
- Node.js 20+
- Redis (for SolidQueue)

## Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd monaco-rgpd

# Install dependencies
bundle install
npm install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start development server
bin/dev
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```
DATABASE_URL=postgresql://localhost/monaco_rgpd_development
REDIS_URL=redis://localhost:6379/0
```

## Seeding Data

The seeds include:
- Compliance areas (5 areas)
- Master questionnaire (5 sections, ~15 questions)
- Document templates (4 templates)

To re-seed:
```bash
rails db:seed
```

## Running Tests

```bash
# All tests
rails test

# With coverage
COVERAGE=true rails test
```

## Background Jobs

Development uses SolidQueue (PostgreSQL-backed queue):

```bash
# Jobs run automatically with bin/dev
# To run manually:
rails solid_queue:start
```

## Next Steps

1. Review and refine questionnaire questions with lawyer
2. Customize document templates
3. Configure production environment
4. Deploy to EU hosting
```

**Step 2: Create architecture documentation**

Create `docs/ARCHITECTURE.md`:
```markdown
# Monaco RGPD - Architecture

## Overview

Monaco RGPD is a Rails 8 + Inertia.js + Svelte 5 SaaS platform for GDPR compliance.

## Tech Stack

- **Backend:** Rails 8.0.3
- **Database:** PostgreSQL 18
- **Frontend:** Svelte 5 + Inertia.js
- **Styling:** Tailwind CSS
- **Jobs:** SolidQueue
- **PDF Generation:** Prawn
- **Templates:** Liquid

## Domain Model

### Core Entities

1. **Account** - Multi-tenant organization
2. **User** - User within an account
3. **Questionnaire** - Master compliance questionnaire
4. **Response** - User's questionnaire submission
5. **ComplianceAssessment** - Calculated compliance score
6. **Document** - Generated compliance documents
7. **ProcessingActivity** - Article 30 register entry

### Key Relationships

```
Account
  ├── Users
  ├── Responses
  │   ├── Answers
  │   ├── ComplianceAssessment
  │   └── Documents
  └── ProcessingActivities
      ├── ProcessingPurposes
      ├── DataCategoryDetails
      ├── AccessCategories
      └── RecipientCategories

Questionnaire
  └── Sections
      └── Questions
          └── AnswerChoices
```

## Background Jobs

- **CalculateComplianceScoreJob** - Calculates compliance score after response completion
- **GenerateDocumentsJob** - Generates PDF documents from templates

## Security

- Multi-tenant row-level isolation via `account_id`
- JSONB encryption for sensitive data
- TLS 1.3 for all connections
- CSRF protection
- Content Security Policy

## Deployment

- Kamal 2 for containerized deployment
- EU-based hosting (Hetzner/OVH)
- PostgreSQL with encrypted backups
- Redis for queue backend
```

**Step 3: Commit**

```bash
git add .
git commit -m "docs: add setup and architecture documentation"
```

---

## Execution Complete!

**Plan saved to:** `docs/plans/2025-10-14-monaco-rgpd-mvp.md`

This implementation plan provides:

- **18 detailed tasks** covering all MVP features
- **TDD approach** with tests written first
- **Exact file paths** and code for each step
- **Frequent commits** after each task
- **Complete data model** matching APDP requirements
- **Svelte 5 frontend** with responsive UI
- **Background jobs** for scoring and document generation
- **Seed data** for questionnaire and templates

**Estimated Timeline:** 8-10 weeks solo development

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach would you prefer?**
