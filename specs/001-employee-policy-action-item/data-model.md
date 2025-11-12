# Data Model: Employee Privacy Policy Distribution Reminder

**Date**: 2025-11-12
**Feature**: 001-employee-policy-action-item

## Overview

This feature does not introduce new database tables. It leverages existing entities and relationships to create action item reminders when users indicate they have employees.

## Existing Entities (No Schema Changes)

### ActionItem (existing)

**Purpose**: Represents tasks/reminders for users to complete

**Schema** (app/models/action_item.rb):
```ruby
create_table "action_items" do |t|
  t.bigint "account_id", null: false
  t.jsonb "action_params", default: {}
  t.integer "action_type", default: 0, null: false
  t.bigint "actionable_id", null: false
  t.string "actionable_type", null: false
  t.text "description"
  t.datetime "due_at"
  t.integer "impact_score"
  t.integer "priority", default: 1, null: false
  t.datetime "snoozed_until"
  t.integer "source", default: 0, null: false
  t.integer "status", default: 0, null: false
  t.string "title", null: false
  t.timestamps
end
```

**Enums**:
- `source`: [:assessment, :regulatory_deadline, :system_recommendation]
- `priority`: [:low, :medium, :high, :critical]
- `status`: [:pending, :in_progress, :completed, :dismissed]
- `action_type`: [:update_treatment, :generate_document, :complete_wizard, :respond_to_sar, :notify_breach]

**Relationships**:
- `belongs_to :account`
- `belongs_to :actionable, polymorphic: true`

**Usage for This Feature**:
- `account`: The business account that must distribute the policy
- `actionable`: Polymorphic reference to Response (the questionnaire submission)
- `source`: Set to `:assessment` (originated from questionnaire)
- `action_type`: Set to `:generate_document` (repurposed for "distribute document")
- `priority`: Set to `:high` (legal compliance requirement)
- `status`: Initially `:pending`
- `title`: "Envoyer politique de confidentialité à vos salariés"
- `description`: Explanation of Monaco Law 1.565 obligation

### Answer (modified - callback only)

**Purpose**: Stores individual answers to questionnaire questions

**Schema** (app/models/answer.rb):
```ruby
create_table "answers" do |t|
  t.boolean "answer_boolean"
  t.bigint "answer_choice_id"
  t.date "answer_date"
  t.decimal "answer_number"
  t.integer "answer_rating"
  t.text "answer_text"
  t.decimal "calculated_score"
  t.bigint "question_id", null: false
  t.bigint "response_id", null: false
  t.timestamps
end
```

**Relationships**:
- `belongs_to :response`
- `belongs_to :question`
- `belongs_to :answer_choice, optional: true`

**Modification**:
- Add `after_commit` callback to trigger action item creation
- No schema changes

### Response (existing, no changes)

**Purpose**: Represents a complete questionnaire submission

**Schema**:
```ruby
create_table "responses" do |t|
  t.bigint "account_id", null: false
  t.datetime "completed_at"
  t.bigint "questionnaire_id", null: false
  t.bigint "respondent_id", null: false
  t.datetime "started_at"
  t.integer "status", default: 0, null: false
  t.timestamps
end
```

**Relationships**:
- `belongs_to :account`
- `belongs_to :questionnaire`
- `belongs_to :respondent` (User)
- `has_many :answers`
- `has_many :documents`

**Usage**: Linked as `actionable` in created ActionItem

### Document (existing, no changes)

**Purpose**: Generated compliance documents (privacy policies, etc.)

**Schema**:
```ruby
create_table "documents" do |t|
  t.bigint "account_id", null: false
  t.integer "document_type", null: false
  t.datetime "generated_at"
  t.bigint "response_id", null: false
  t.integer "status", default: 0, null: false
  t.string "title", null: false
  t.timestamps
end
```

**Relationships**:
- `belongs_to :account`
- `belongs_to :response`
- `has_one_attached :file` (via ActiveStorage)

**Usage**: Referenced indirectly via `response.documents` for action item description/links

### Question (existing, reference only)

**Purpose**: Defines questionnaire questions

**Key Question**:
- `question_text`: "Avez-vous du personnel ?"
- This is the trigger question that determines action item creation

## Entity Relationships Diagram

```text
┌─────────────┐
│   Account   │
└──────┬──────┘
       │
       ├─────────────┐
       │             │
       ▼             ▼
┌─────────────┐ ┌──────────────┐
│  Response   │ │  ActionItem  │
│             │ │              │
│ actionable  │◄┼──┐           │
│  (polymorphic) │  │           │
└──────┬──────┘ └──────────────┘
       │
       ├──────┐
       │      │
       ▼      ▼
┌──────────┐ ┌──────────┐
│  Answer  │ │ Document │
└──────────┘ └──────────┘
```

## Data Flow

1. **User answers employee question**:
   ```
   Answer created/updated → answer_choice.choice_text == "Oui"
   ```

2. **Callback triggers service**:
   ```
   Answer.after_commit → EmployeePolicyActionCreator.call
   ```

3. **Service checks conditions**:
   ```
   - Is this the "Avez-vous du personnel ?" question?
   - Is the answer "Oui"?
   - Does action item already exist for this response?
   ```

4. **Action item created**:
   ```
   ActionItem.create!(
     account: response.account,
     actionable: response,
     source: :assessment,
     action_type: :generate_document,
     priority: :high,
     status: :pending,
     title: "Envoyer politique de confidentialité à vos salariés",
     description: "..."
   )
   ```

## Queries

### Check for Existing Action Item (Deduplication)
```ruby
ActionItem.exists?(
  account_id: account.id,
  actionable_type: 'Response',
  actionable_id: response.id,
  source: :assessment,
  action_type: :generate_document
)
```

**Indexes Used**:
- `index_action_items_on_account_id`
- `index_action_items_on_actionable_type_and_actionable_id`

### Find Employee Question Answer
```ruby
answer.response.answers
  .joins(:question)
  .find_by(questions: { question_text: "Avez-vous du personnel ?" })
```

**Indexes Used**:
- `index_answers_on_response_id_and_question_id`
- `index_questions_on_section_id` (via join)

### Get Action Items for Account
```ruby
ActionItem.where(account: account)
  .where(status: [:pending, :in_progress])
  .order(priority: :desc, created_at: :desc)
```

**Indexes Used**:
- `index_action_items_on_account_id_and_status`
- `index_action_items_on_account_id_and_priority`

## Validation Rules

### ActionItem (from existing model)
- `title`: Required (presence validation)
- `source`: Required (enum validation)
- `account`: Required (foreign key)
- `actionable`: Required (polymorphic foreign key)

### No Additional Validations
This feature uses existing validations. No new rules required.

## State Transitions

### ActionItem Status
```text
[pending] ──(user marks complete)──> [completed]
    │
    └──(user dismisses)──> [dismissed]
    │
    └──(user starts work)──> [in_progress] ──(finishes)──> [completed]
```

**No state machine required**: Simple status enum updates via controller actions.

## Performance Considerations

### Query Performance
- All queries use existing indexes
- Deduplication query is O(1) lookup (indexed columns)
- No N+1 queries (all relationships preloaded by service)

### Creation Performance
- Action item creation: <10ms (single INSERT)
- Callback overhead: <5ms (conditional early return if not employee question)
- Total impact: <15ms per answer save (well within 100ms requirement)

### Concurrency
- `after_commit` ensures transaction safety
- Deduplication query in service prevents race condition duplicates
- No locks required (optimistic concurrency via created_at)

## Summary

**Schema Changes**: None
**Modified Models**: Answer (callback only)
**New Service**: EmployeePolicyActionCreator
**Leveraged Entities**: ActionItem, Response, Document, Question
**Indexes**: All existing (no new indexes needed)
**Performance**: <15ms overhead, all queries indexed
