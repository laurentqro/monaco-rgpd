# Answer Schema Refactor: JSONB to Separate Fields (Simplified)

> **For Claude:** Use `/superpowers:execute-plan` to implement this plan task-by-task.

**Goal:** Replace JSONB `answer_value` field with explicit typed fields (`answer_choice_id`, `answer_text`, etc.) for better data integrity and type safety.

**Why Simplified:** No existing production data to migrate. Clean slate refactor.

**Architecture:** Direct replacement - remove JSONB, use separate fields, add database constraints.

**Tech Stack:** Rails 8.0.3, PostgreSQL 18, existing Answer/Question/AnswerChoice models

---

## Task 1: Update Answer Model to Use Separate Fields

**Files:**
- Modify: `app/models/answer.rb`
- Test: `test/models/answer_test.rb`

**Step 1: Update Answer model**

Replace `app/models/answer.rb` completely:

```ruby
class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question
  belongs_to :answer_choice, optional: true

  validates :question_id, uniqueness: { scope: :response_id }
  validate :exactly_one_answer_field_present

  after_save :calculate_score

  def answer_choice_text
    answer_choice&.choice_text
  end

  def answer_text_value
    answer_text
  end

  def answer_numeric_value
    answer_number || answer_rating
  end

  private

  def calculate_score
    return nil unless question.weight.present?
    # Score calculation logic will be implemented based on question type
  end

  def exactly_one_answer_field_present
    fields = [
      answer_choice_id,
      answer_text,
      answer_rating,
      answer_number,
      answer_date
    ].compact

    has_boolean = !answer_boolean.nil?

    total_fields = fields.count + (has_boolean ? 1 : 0)

    if total_fields == 0
      errors.add(:base, "At least one answer field must be present")
    elsif total_fields > 1
      errors.add(:base, "Only one answer field can be set")
    end
  end
end
```

**Step 2: Update tests**

Replace `test/models/answer_test.rb`:

```ruby
require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  test "creates answer with answer_choice" do
    question = questions(:one)
    choice = question.answer_choices.first

    answer = Answer.create!(
      response: responses(:one),
      question: question,
      answer_choice: choice,
      calculated_score: 100.0
    )

    assert_equal choice, answer.answer_choice
    assert_equal choice.choice_text, answer.answer_choice_text
  end

  test "creates answer with answer_text" do
    question = questions(:one)

    answer = Answer.create!(
      response: responses(:one),
      question: question,
      answer_text: "Sample text response",
      calculated_score: 50.0
    )

    assert_equal "Sample text response", answer.answer_text
  end

  test "requires at least one answer field" do
    answer = Answer.new(
      response: responses(:one),
      question: questions(:one)
    )

    assert_not answer.valid?
    assert_includes answer.errors[:base], "At least one answer field must be present"
  end

  test "prevents multiple answer fields" do
    answer = Answer.new(
      response: responses(:one),
      question: questions(:one),
      answer_text: "text",
      answer_rating: 5
    )

    assert_not answer.valid?
    assert_includes answer.errors[:base], "Only one answer field can be set"
  end
end
```

**Step 3: Run tests**

```bash
bin/rails test test/models/answer_test.rb
```

Expected: 4 tests pass

**Step 4: Commit**

```bash
git add app/models/answer.rb test/models/answer_test.rb
git commit -m "refactor: replace answer_value JSONB with separate typed fields"
```

---

## Task 2: Remove answer_value Column

**Files:**
- Create: `db/migrate/[timestamp]_remove_answer_value_from_answers.rb`

**Step 1: Generate migration**

```bash
bin/rails generate migration RemoveAnswerValueFromAnswers
```

**Step 2: Edit migration**

```ruby
class RemoveAnswerValueFromAnswers < ActiveRecord::Migration[8.1]
  def up
    remove_column :answers, :answer_value
  end

  def down
    add_column :answers, :answer_value, :jsonb, default: {}, null: false
  end
end
```

**Step 3: Run migration**

```bash
bin/rails db:migrate
```

Expected: Column removed successfully

**Step 4: Commit**

```bash
git add db/migrate db/schema.rb
git commit -m "refactor: remove answer_value JSONB column"
```

---

## Task 3: Add Database Constraint

**Files:**
- Create: `db/migrate/[timestamp]_add_answer_field_constraint.rb`

**Step 1: Generate migration**

```bash
bin/rails generate migration AddAnswerFieldConstraint
```

**Step 2: Edit migration**

```ruby
class AddAnswerFieldConstraint < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      ALTER TABLE answers
      ADD CONSTRAINT exactly_one_answer_field CHECK (
        (
          (CASE WHEN answer_choice_id IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_text IS NOT NULL AND answer_text != '' THEN 1 ELSE 0 END) +
          (CASE WHEN answer_rating IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_number IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_date IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_boolean IS NOT NULL THEN 1 ELSE 0 END)
        ) = 1
      )
    SQL
  end

  def down
    execute "ALTER TABLE answers DROP CONSTRAINT exactly_one_answer_field"
  end
end
```

**Step 3: Run migration**

```bash
bin/rails db:migrate
```

Expected: Constraint added successfully

**Step 4: Test constraint**

```bash
bin/rails runner "
  # Should fail - no fields
  begin
    Answer.create!(response: Response.first, question: Question.first)
    puts '❌ Constraint not working'
  rescue ActiveRecord::StatementInvalid
    puts '✓ Constraint prevents empty answers'
  end

  # Should fail - multiple fields
  begin
    Answer.create!(response: Response.first, question: Question.last, answer_text: 'x', answer_rating: 5)
    puts '❌ Constraint not working'
  rescue ActiveRecord::StatementInvalid
    puts '✓ Constraint prevents multiple fields'
  end
"
```

Expected: Both checks pass

**Step 5: Commit**

```bash
git add db/migrate db/schema.rb
git commit -m "feat: add database constraint for exactly one answer field"
```

---

## Task 4: Update ConversationOrchestrator

**Files:**
- Modify: `app/services/conversation_orchestrator.rb`

**Step 1: Update create_answer_for_question**

Find the method (around line 204) and replace:

```ruby
def create_answer_for_question(question, answer_data)
  # Find existing answer or create new one
  answer = conversation.response.answers.find_or_initialize_by(question: question)

  # Use separate typed fields
  case question.question_type
  when "yes_no", "single_choice"
    choice = question.answer_choices.find_by(choice_text: answer_data[:value])
    return unless choice

    answer.answer_choice = choice
    answer.calculated_score = choice.score

  when "text_short", "text_long"
    answer.answer_text = answer_data[:value]
    answer.calculated_score = 50.0
  end

  answer.save!
end
```

**Step 2: Run tests**

```bash
bin/rails test test/services/conversation_orchestrator_test.rb
```

Expected: Tests pass

**Step 3: Commit**

```bash
git add app/services/conversation_orchestrator.rb
git commit -m "refactor: use separate fields in ConversationOrchestrator"
```

---

## Task 5: Update AnswersController

**Files:**
- Modify: `app/controllers/answers_controller.rb`

**Step 1: Find answer creation code**

```bash
grep -n "answer_value" app/controllers/answers_controller.rb
```

**Step 2: Replace JSONB with separate fields**

Change from:
```ruby
answer.update!(answer_value: params[:answer_value])
```

To:
```ruby
case answer.question.question_type
when "yes_no", "single_choice"
  answer.update!(answer_choice_id: params[:choice_id])
when "text_short", "text_long"
  answer.update!(answer_text: params[:text])
when "rating"
  answer.update!(answer_rating: params[:rating])
end
```

**Step 3: Run tests**

```bash
bin/rails test test/controllers/answers_controller_test.rb
```

Expected: Tests pass

**Step 4: Commit**

```bash
git add app/controllers/answers_controller.rb
git commit -m "refactor: use separate fields in AnswersController"
```

---

## Task 6: Update ComplianceScorer

**Files:**
- Modify: `app/services/compliance_scorer.rb`

**Step 1: Find JSONB access**

```bash
grep -n "answer_value\[" app/services/compliance_scorer.rb
```

**Step 2: Replace with direct field access**

Change:
```ruby
choice = question.answer_choices.find_by(id: answer.answer_value["choice_id"])
```

To:
```ruby
choice = answer.answer_choice
```

**Step 3: Run tests**

```bash
bin/rails test test/services/compliance_scorer_test.rb
```

Expected: Tests pass

**Step 4: Commit**

```bash
git add app/services/compliance_scorer.rb
git commit -m "refactor: use separate fields in ComplianceScorer"
```

---

## Task 7: Update PrivacyPolicyGenerator

**Files:**
- Modify: `app/services/privacy_policy_generator.rb`

**Step 1: Find JSONB access**

```bash
grep -n "answer_value\[" app/services/privacy_policy_generator.rb
```

**Step 2: Replace with direct field access**

Change JSONB lookups to use `answer.answer_choice`, `answer.answer_text`, etc.

**Step 3: Run tests**

```bash
bin/rails test test/services/privacy_policy_generator_test.rb
```

Expected: Tests pass

**Step 4: Commit**

```bash
git add app/services/privacy_policy_generator.rb
git commit -m "refactor: use separate fields in PrivacyPolicyGenerator"
```

---

## Task 8: Final Verification

**Files:**
- N/A (testing)

**Step 1: Run full test suite**

```bash
bin/rails test
```

Expected: All tests pass

**Step 2: Verify no JSONB references remain**

```bash
grep -r "answer_value" app/ --include="*.rb"
```

Expected: No matches (field removed)

**Step 3: Check schema**

```bash
bin/rails runner "puts Answer.column_names"
```

Expected: No answer_value in list

**Step 4: Manual test**

1. Start AI chat conversation
2. Answer questions with buttons and text
3. Check database: `Answer.last`
4. Verify separate fields populated

**Step 5: Create summary**

```bash
git log --oneline master..HEAD
```

Expected: ~8 commits

---

## Success Criteria

- [ ] answer_value column removed
- [ ] All code uses separate fields
- [ ] Database constraint enforces one field
- [ ] All tests passing
- [ ] AI chat works correctly
- [ ] Traditional form works correctly

---

## Timeline

**Estimated: 4-6 hours** (much faster without data migration!)

- Task 1: 30 min (model update)
- Task 2: 15 min (remove column)
- Task 3: 15 min (add constraint)
- Tasks 4-7: 2-3 hours (update all code)
- Task 8: 30 min (verification)
