# Quickstart: Employee Privacy Policy Distribution Reminder

**Date**: 2025-11-12
**Feature**: 001-employee-policy-action-item
**Branch**: `001-employee-policy-action-item`

## Overview

Automatically create action item reminders when users indicate they have employees during the compliance questionnaire. This ensures business owners don't overlook the legal requirement to distribute employee privacy policies.

## 5-Minute Implementation Guide

### Step 1: Create Service Object (TDD)

**Test First** (`test/services/employee_policy_action_creator_test.rb`):
```ruby
require "test_helper"

class EmployeePolicyActionCreatorTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:standard)
    @response = responses(:compliance)
    @employee_question = questions(:has_employees)
    @answer = Answer.create!(
      response: @response,
      question: @employee_question,
      answer_choice: answer_choices(:yes)
    )
  end

  test "creates action item when answer is Oui to employee question" do
    assert_difference "ActionItem.count", 1 do
      EmployeePolicyActionCreator.new(@answer).call
    end

    action_item = ActionItem.last
    assert_equal @account, action_item.account
    assert_equal @response, action_item.actionable
    assert_equal "Envoyer politique de confidentialité à vos salariés", action_item.title
    assert_equal "assessment", action_item.source
    assert_equal "high", action_item.priority
  end

  test "does not create duplicate action items" do
    EmployeePolicyActionCreator.new(@answer).call

    assert_no_difference "ActionItem.count" do
      EmployeePolicyActionCreator.new(@answer).call
    end
  end

  test "does not create action item for non-employee question" do
    other_answer = Answer.create!(
      response: @response,
      question: questions(:other),
      answer_choice: answer_choices(:yes)
    )

    assert_no_difference "ActionItem.count" do
      EmployeePolicyActionCreator.new(other_answer).call
    end
  end
end
```

**Implementation** (`app/services/employee_policy_action_creator.rb`):
```ruby
class EmployeePolicyActionCreator
  EMPLOYEE_QUESTION_TEXT = "Avez-vous du personnel ?".freeze
  ACTION_TITLE = "Envoyer politique de confidentialité à vos salariés".freeze
  ACTION_DESCRIPTION = <<~DESC.squish
    Selon la Loi n° 1.565, vous devez informer vos salariés des données personnelles
    collectées, des finalités du traitement, et de la base légale. Veuillez distribuer
    la politique de confidentialité des salariés à l'ensemble de votre personnel.
  DESC

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

  private

  def should_create_action_item?
    return false unless @answer.question.question_text == EMPLOYEE_QUESTION_TEXT
    return false unless is_yes_answer?(@answer)
    true
  end

  def is_yes_answer?(answer)
    if answer.answer_choice.present?
      answer.answer_choice.choice_text == "Oui"
    elsif answer.answer_text.present?
      answer.answer_text == "Oui"
    else
      false
    end
  end

  def action_item_already_exists?
    ActionItem.exists?(
      account: @account,
      actionable: @response,
      source: :assessment,
      action_type: :generate_document
    )
  end

  def create_action_item!
    ActionItem.create!(
      account: @account,
      actionable: @response,
      source: :assessment,
      action_type: :generate_document,
      priority: :high,
      status: :pending,
      title: ACTION_TITLE,
      description: ACTION_DESCRIPTION
    )
  end
end
```

### Step 2: Add Answer Callback

**Test First** (`test/models/answer_test.rb`):
```ruby
test "creates employee policy action item after commit when answer is Oui" do
  question = questions(:has_employees)
  response = responses(:compliance)

  assert_difference "ActionItem.count", 1 do
    Answer.create!(
      response: response,
      question: question,
      answer_choice: answer_choices(:yes)
    )
  end
end

test "does not create action item when answer is Non" do
  question = questions(:has_employees)
  response = responses(:compliance)

  assert_no_difference "ActionItem.count" do
    Answer.create!(
      response: response,
      question: question,
      answer_choice: answer_choices(:no)
    )
  end
end
```

**Implementation** (`app/models/answer.rb`):
```ruby
class Answer < ApplicationRecord
  # ... existing code ...

  after_commit :create_employee_policy_action_item, on: [:create, :update]

  private

  def create_employee_policy_action_item
    EmployeePolicyActionCreator.new(self).call
  rescue => e
    Rails.logger.error("Failed to create employee policy action item: #{e.message}")
    # Don't re-raise - allow answer save to succeed
  end
end
```

### Step 3: Add Integration Test

**Test** (`test/integration/employee_policy_action_flow_test.rb`):
```ruby
require "test_helper"

class EmployeePolicyActionFlowTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:standard)
    @user = users(:standard_user)
    @questionnaire = questionnaires(:compliance)
    sign_in @user
  end

  test "completing questionnaire with employees creates action item" do
    # Start questionnaire
    post responses_path, params: {
      response: { questionnaire_id: @questionnaire.id }
    }
    response = Response.last

    # Answer employee question with "Oui"
    question = questions(:has_employees)
    yes_choice = answer_choices(:yes)

    assert_difference "ActionItem.count", 1 do
      post answers_path, params: {
        answer: {
          response_id: response.id,
          question_id: question.id,
          answer_choice_id: yes_choice.id
        }
      }
    end

    # Verify action item created
    action_item = ActionItem.last
    assert_equal "Envoyer politique de confidentialité à vos salariés", action_item.title
    assert_equal @account, action_item.account
    assert_equal "pending", action_item.status

    # Verify user can see it in dashboard
    get action_items_path
    assert_response :success
    # Inertia.js response contains action_items prop
  end
end
```

### Step 4: Run Tests

```bash
# Run service tests
bin/rails test test/services/employee_policy_action_creator_test.rb

# Run model tests
bin/rails test test/models/answer_test.rb

# Run integration test
bin/rails test test/integration/employee_policy_action_flow_test.rb

# Run all tests
bin/rails test
```

### Step 5: Verify in UI

1. Start development server: `bin/dev`
2. Sign in to application
3. Start compliance questionnaire
4. Answer "Oui" to "Avez-vous du personnel ?"
5. Navigate to `/action_items`
6. Verify action item appears with:
   - Title: "Envoyer politique de confidentialité à vos salariés"
   - Priority: High (red/orange indicator)
   - Status: Pending

## Implementation Checklist

- [ ] Create `EmployeePolicyActionCreator` service with tests
- [ ] Add `after_commit` callback to `Answer` model
- [ ] Add callback tests to `answer_test.rb`
- [ ] Create integration test for end-to-end flow
- [ ] Run Rubocop: `bin/rubocop app/services/employee_policy_action_creator.rb`
- [ ] Run all tests: `bin/rails test`
- [ ] Manual UI verification in development
- [ ] Verify no N+1 queries (check logs during manual test)
- [ ] Commit with message following project conventions

## Files Modified/Created

```text
✅ Created:
- app/services/employee_policy_action_creator.rb
- test/services/employee_policy_action_creator_test.rb
- test/integration/employee_policy_action_flow_test.rb

✅ Modified:
- app/models/answer.rb (add after_commit callback)
- test/models/answer_test.rb (add callback tests)
```

## Testing Fixtures

**Add to `test/fixtures/questions.yml`**:
```yaml
has_employees:
  section: onboarding
  question_text: "Avez-vous du personnel ?"
  question_type: single_choice
  order_index: 5
  is_required: true
```

**Add to `test/fixtures/answer_choices.yml`**:
```yaml
yes:
  question: has_employees
  choice_text: "Oui"
  order_index: 1

no:
  question: has_employees
  choice_text: "Non"
  order_index: 2
```

## Common Issues

### Issue: Action item not created
**Solution**: Check logs for errors, ensure question text matches exactly "Avez-vous du personnel ?"

### Issue: Duplicate action items
**Solution**: Service has deduplication logic - check if `actionable` relationship is correct

### Issue: Callback not firing
**Solution**: Ensure using `after_commit` (not `after_save`), check transaction boundaries

### Issue: Tests failing
**Solution**: Ensure fixtures are loaded, check foreign key constraints

## Performance Check

```ruby
# In Rails console:
require 'benchmark'

response = Response.last
question = Question.find_by(question_text: "Avez-vous du personnel ?")
yes_choice = question.answer_choices.find_by(choice_text: "Oui")

time = Benchmark.measure do
  Answer.create!(
    response: response,
    question: question,
    answer_choice: yes_choice
  )
end

puts "Total time: #{time.real * 1000}ms"  # Should be < 100ms
```

## Next Steps

After implementation:
1. Run `/speckit.tasks` to generate task breakdown
2. Follow TDD workflow: Red → Green → Refactor
3. Create PR with comprehensive test coverage
4. Deploy to staging for manual QA
5. Monitor logs for any errors in production

## Questions?

Refer to:
- [research.md](./research.md) - Technical decisions
- [data-model.md](./data-model.md) - Entity relationships
- [contracts/action_item.md](./contracts/action_item.md) - API structure
- [spec.md](./spec.md) - Business requirements
