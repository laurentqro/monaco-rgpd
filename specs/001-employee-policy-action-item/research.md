# Research: Employee Privacy Policy Distribution Reminder

**Date**: 2025-11-12
**Feature**: 001-employee-policy-action-item

## Overview

Research findings for implementing automatic action item creation when users indicate they have employees in the compliance questionnaire.

## Decision 1: Callback vs Observer Pattern

**Decision**: Use ActiveRecord `after_commit` callback (not `after_save`)

**Rationale**:
- `after_commit` ensures action item is only created after database transaction commits successfully
- Prevents orphaned action items if questionnaire save fails or rolls back
- Safer for concurrent submissions and transaction integrity
- Rails 8 best practice for side effects that depend on persisted state

**Alternatives Considered**:
- `after_save`: Rejected - runs within transaction, could create action item even if transaction rolls back
- Observer pattern: Rejected - overkill for single callback, adds unnecessary abstraction
- Background job: Rejected - user expects immediate feedback, <100ms performance requirement

**Implementation**:
```ruby
class Answer < ApplicationRecord
  after_commit :create_employee_policy_action_item, on: [:create, :update]
end
```

## Decision 2: Service Object Pattern

**Decision**: Create `EmployeePolicyActionCreator` service object

**Rationale**:
- Keeps Answer model thin (single responsibility)
- Encapsulates complex business logic (check for employees answer, find/create document, deduplicate)
- Easier to test in isolation
- Aligns with Rails omakase recommendation for business logic extraction

**Alternatives Considered**:
- Inline in Answer model: Rejected - would bloat Answer model with domain logic unrelated to answer persistence
- Concern module: Rejected - not reusable across models, just organizing code
- Plain old Ruby object (PORO): Same as service object - chosen for clarity of naming

**Interface**:
```ruby
class EmployeePolicyActionCreator
  def initialize(answer)
    @answer = answer
    @response = answer.response
    @account = @response.account
  end

  def call
    return unless should_create_action_item?
    return if action_item_already_exists?

    create_action_item!
  end
end
```

## Decision 3: Deduplication Strategy

**Decision**: Query for existing action item by account + source + actionable before creating

**Rationale**:
- Prevents duplicate reminders for same response
- Handles questionnaire re-submission gracefully
- Uses existing indexed columns (account_id, actionable_type, actionable_id)
- Idempotent operation - safe to call multiple times

**Alternatives Considered**:
- Database unique constraint: Rejected - too rigid, prevents legitimate use cases (e.g., multiple questionnaires)
- Track in separate junction table: Rejected - unnecessary complexity
- Flag on Response model: Rejected - couples Response to action item logic

**Implementation**:
```ruby
def action_item_already_exists?
  ActionItem.exists?(
    account: @account,
    source: :assessment,
    actionable: @response,
    action_type: :generate_document  # Repurpose existing enum value
  )
end
```

## Decision 4: Linking Strategy

**Decision**: Link action item to Response (polymorphic actionable), not Document

**Rationale**:
- Response is the trigger source (stable reference point)
- Document may not exist yet if generation fails
- Allows action item creation even if document generation is async/delayed
- Can look up document later via `response.documents.find_by(document_type: :employee_privacy_policy)`

**Alternatives Considered**:
- Link to Document: Rejected - couples action item creation to document existence
- Link to both Response and Document: Rejected - redundant, Response → Document relationship already exists
- Link to Question: Rejected - wrong level of granularity

## Decision 5: Action Item Attributes

**Decision**: Use existing ActionItem enums and fields

**Rationale**:
- `source: :assessment` - originated from questionnaire assessment
- `action_type: :generate_document` - closest existing enum (semantically: "distribute document")
- `priority: :high` - legal compliance requirement
- `title`: "Envoyer politique de confidentialité à vos salariés" (from spec FR-002)
- `description`: Brief explanation of Monaco Law 1.565 obligation
- `actionable`: polymorphic to Response

**Alternatives Considered**:
- Add new enum values: Rejected - existing values suffice, avoids migration
- Create new action item subtype: Rejected - unnecessary inheritance complexity

**No Schema Changes Required**: Existing action_items table supports all needed fields.

## Decision 6: Testing Strategy

**Decision**: Three-layer testing approach

**Rationale**:
- **Unit tests** (service object): Test business logic in isolation
- **Model tests** (Answer callback): Verify callback triggers service
- **Integration tests**: End-to-end flow from answer save to action item creation

**Test Cases**:
1. Answer "Oui" to employee question → action item created
2. Answer "Non" to employee question → no action item
3. Change answer from "Non" to "Oui" → action item created
4. Re-submit same response → no duplicate action item
5. Multiple responses, same account → separate action items
6. Transaction rollback → no action item created

## Decision 7: Error Handling

**Decision**: Fail silently with logging, don't block questionnaire save

**Rationale**:
- Action item is nice-to-have reminder, not critical to questionnaire completion
- User can still complete compliance assessment if action item creation fails
- Logging enables monitoring and debugging without user impact

**Implementation**:
```ruby
def create_employee_policy_action_item
  EmployeePolicyActionCreator.new(self).call
rescue => e
  Rails.logger.error("Failed to create employee policy action item: #{e.message}")
  # Don't re-raise - allow questionnaire save to succeed
end
```

**Alternatives Considered**:
- Re-raise exception: Rejected - blocks user from completing questionnaire
- Background retry job: Rejected - adds complexity, 100ms requirement means sync is fine
- User notification: Rejected - confusing UX, action items dashboard will show state

## Summary

**Key Technical Choices**:
1. `after_commit` callback for transaction safety
2. Service object for business logic encapsulation
3. Query-based deduplication (idempotent)
4. Link to Response (stable reference)
5. Reuse existing ActionItem enums (no migration)
6. Three-layer testing strategy
7. Fail silently with logging

**No Open Questions**: All technical decisions resolved. Ready for Phase 1 design.
