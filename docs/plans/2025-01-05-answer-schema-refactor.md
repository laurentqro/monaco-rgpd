# Answer Schema Refactor: JSONB to Separate Fields

> **For Claude:** Use `/superpowers:execute-plan` to implement this plan task-by-task.

**Goal:** Refactor the Answer model from flexible JSONB (`answer_value`) to explicit typed fields (`answer_choice_id`, `answer_text`, etc.) for better data integrity, queryability, and type safety in this compliance application.

**Why:** Compliance data must be auditable and trustworthy. Separate fields provide database-level constraints, foreign key integrity, better query performance, and clearer semantics.

**Approach:** Zero-downtime migration with dual-write period, allowing rollback if issues arise.

**Tech Stack:** Rails 8.0.3, PostgreSQL 18, existing Answer/Question/AnswerChoice models

---

## Prerequisites

- [ ] AI chat feature is stable and tested in production
- [ ] Full database backup taken
- [ ] All tests passing before starting
- [ ] Stakeholder approval for schema change

---

## Phase 1: Add New Fields (Dual-Write Begins)

### Task 1: Add Separate Answer Fields

**Files:**
- Create: `db/migrate/[timestamp]_add_separate_answer_fields.rb`
- Modify: `app/models/answer.rb`
- Test: `test/models/answer_test.rb`

**Step 1: Create migration**

```bash
bin/rails generate migration AddSeparateAnswerFields
```

**Step 2: Edit migration**

```ruby
class AddSeparateAnswerFields < ActiveRecord::Migration[8.1]
  def change
    # Add separate typed fields
    add_reference :answers, :answer_choice, foreign_key: { to_table: :answer_choices }, null: true
    add_column :answers, :answer_text, :text, null: true
    add_column :answers, :answer_rating, :integer, null: true
    add_column :answers, :answer_number, :decimal, precision: 10, scale: 2, null: true
    add_column :answers, :answer_date, :date, null: true
    add_column :answers, :answer_boolean, :boolean, null: true

    # Add indexes for query performance
    add_index :answers, :answer_choice_id
    add_index :answers, :answer_rating

    # Keep answer_value for now (dual-write period)
    # Will be removed in Phase 3 after verification
  end
end
```

**Step 3: Run migration**

```bash
bin/rails db:migrate
```

Expected: Migration succeeds, new columns added

**Step 4: Update Answer model with dual-write**

Edit `app/models/answer.rb`:

```ruby
class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question
  belongs_to :answer_choice, optional: true  # NEW

  validates :answer_value, presence: true  # Keep for now

  # Calculate score based on question type and answer
  after_save :calculate_score

  # NEW: Dual-write callbacks to keep JSONB in sync during migration
  before_save :sync_to_jsonb
  after_save :sync_from_jsonb, if: -> { saved_change_to_answer_value? }

  def answer_choice_text
    # NEW: Use separate field if available
    return answer_choice&.choice_text if answer_choice.present?

    # Fallback to JSONB for legacy data
    choice_id = answer_value["choice_id"] || answer_value[:choice_id]
    return nil unless choice_id
    AnswerChoice.find_by(id: choice_id)&.choice_text
  end

  private

  def calculate_score
    return nil unless question.weight.present?
    # Score calculation logic will be implemented based on question type
  end

  # NEW: Sync separate fields → JSONB (for dual-write period)
  def sync_to_jsonb
    self.answer_value ||= {}

    if answer_choice_id.present?
      self.answer_value["choice_id"] = answer_choice_id
    elsif answer_text.present?
      self.answer_value["text"] = answer_text
    elsif answer_rating.present?
      self.answer_value["rating"] = answer_rating
    elsif answer_number.present?
      self.answer_value["number"] = answer_number
    elsif answer_date.present?
      self.answer_value["date"] = answer_date.to_s
    elsif !answer_boolean.nil?
      self.answer_value["boolean"] = answer_boolean
    end
  end

  # NEW: Sync JSONB → separate fields (for legacy code still writing JSONB)
  def sync_from_jsonb
    return if answer_value.blank?

    if answer_value["choice_id"].present? && answer_choice_id.blank?
      self.answer_choice_id = answer_value["choice_id"]
    elsif answer_value["text"].present? && answer_text.blank?
      self.answer_text = answer_value["text"]
    elsif answer_value["rating"].present? && answer_rating.blank?
      self.answer_rating = answer_value["rating"]
    # ... etc for other types
    end
  end
end
```

**Step 5: Write tests**

Add to `test/models/answer_test.rb`:

```ruby
test "creates answer with answer_choice_id" do
  answer = Answer.create!(
    response: responses(:one),
    question: questions(:one),
    answer_choice: answer_choices(:choice_one),
    calculated_score: 100.0
  )

  assert_equal answer_choices(:choice_one), answer.answer_choice
  # Verify dual-write synced to JSONB
  assert_equal answer_choices(:choice_one).id, answer.answer_value["choice_id"]
end

test "creates answer with answer_text" do
  answer = Answer.create!(
    response: responses(:one),
    question: questions(:text_question),
    answer_text: "Sample text response",
    calculated_score: 50.0
  )

  assert_equal "Sample text response", answer.answer_text
  # Verify dual-write synced to JSONB
  assert_equal "Sample text response", answer.answer_value["text"]
end

test "syncs JSONB to separate fields on save" do
  answer = Answer.create!(
    response: responses(:one),
    question: questions(:one),
    answer_value: { choice_id: answer_choices(:choice_one).id },
    calculated_score: 100.0
  )

  # Verify sync from JSONB to separate field
  assert_equal answer_choices(:choice_one).id, answer.answer_choice_id
end
```

**Step 6: Run tests**

```bash
bin/rails test test/models/answer_test.rb
```

Expected: All tests pass

**Step 7: Commit**

```bash
git add db/migrate app/models/answer.rb test/models/answer_test.rb
git commit -m "feat: add separate answer fields with dual-write sync"
```

---

## Phase 2: Migrate Existing Data

### Task 2: Backfill Separate Fields from JSONB

**Files:**
- Create: `lib/tasks/answer_migration.rake`

**Step 1: Create rake task**

Create `lib/tasks/answer_migration.rake`:

```ruby
namespace :answers do
  desc "Migrate answer_value JSONB to separate typed fields"
  task migrate_to_separate_fields: :environment do
    puts "Starting Answer migration..."

    total = Answer.count
    migrated = 0
    errors = []

    Answer.find_each.with_index do |answer, index|
      begin
        # Skip if already migrated
        next if answer_already_migrated?(answer)

        case answer.question.question_type
        when "yes_no", "single_choice"
          choice_id = answer.answer_value["choice_id"] || answer.answer_value[:choice_id]
          answer.update_columns(answer_choice_id: choice_id) if choice_id.present?

        when "multiple_choice"
          # Store as array in JSONB for now, or create multiple Answer records
          # Decision needed based on business requirements

        when "text_short", "text_long"
          text = answer.answer_value["text"] || answer.answer_value[:text]
          answer.update_columns(answer_text: text) if text.present?

        when "rating"
          rating = answer.answer_value["rating"] || answer.answer_value[:rating]
          answer.update_columns(answer_rating: rating) if rating.present?

        when "number"
          number = answer.answer_value["number"] || answer.answer_value[:number]
          answer.update_columns(answer_number: number) if number.present?

        when "date"
          date_str = answer.answer_value["date"] || answer.answer_value[:date]
          answer.update_columns(answer_date: Date.parse(date_str)) if date_str.present?

        when "boolean"
          bool = answer.answer_value["boolean"] || answer.answer_value[:boolean]
          answer.update_columns(answer_boolean: bool) unless bool.nil?
        end

        migrated += 1
        print "\rMigrated #{migrated}/#{total} answers" if (index % 100).zero?

      rescue => e
        errors << { answer_id: answer.id, error: e.message }
      end
    end

    puts "\n✓ Migration complete: #{migrated}/#{total} answers migrated"

    if errors.any?
      puts "\n⚠ Errors encountered:"
      errors.each { |err| puts "  Answer ##{err[:answer_id]}: #{err[:error]}" }
    end
  end

  def answer_already_migrated?(answer)
    # Check if any separate field is populated
    answer.answer_choice_id.present? ||
    answer.answer_text.present? ||
    answer.answer_rating.present? ||
    answer.answer_number.present? ||
    answer.answer_date.present? ||
    !answer.answer_boolean.nil?
  end
end
```

**Step 2: Run migration on development**

```bash
bin/rails answers:migrate_to_separate_fields
```

Expected: All existing answers migrated

**Step 3: Verify migration**

```bash
bin/rails runner "
  total = Answer.count
  migrated = Answer.where.not(answer_choice_id: nil)
                   .or(Answer.where.not(answer_text: nil))
                   .or(Answer.where.not(answer_rating: nil))
                   .count
  puts \"Migrated: #{migrated}/#{total} (#{(migrated.to_f / total * 100).round(2)}%)\"
"
```

Expected: 100% migrated

**Step 4: Test in staging**

Deploy to staging and verify:
- All existing answers display correctly
- New answers save to both fields
- Reports still work
- No data loss

**Step 5: Commit**

```bash
git add lib/tasks/answer_migration.rake
git commit -m "feat: add rake task to migrate answers to separate fields"
```

---

## Phase 3: Update Application Code

### Task 3: Update All Answer Creation Code

**Files to Update:**
- `app/services/conversation_orchestrator.rb` - AI chat (already using new fields!)
- `app/controllers/answers_controller.rb` - Traditional form
- `app/services/compliance_scorer.rb` - Scoring logic
- `app/services/privacy_policy_generator.rb` - Document generation
- Any other code reading/writing answers

**Step 1: Update AnswersController**

In `app/controllers/answers_controller.rb`, change from:

```ruby
# OLD
answer.update!(answer_value: params[:answer_value])
```

To:

```ruby
# NEW
case question.question_type
when "yes_no", "single_choice"
  answer.update!(answer_choice_id: params[:choice_id])
when "text_short", "text_long"
  answer.update!(answer_text: params[:text])
when "rating"
  answer.update!(answer_rating: params[:rating])
# ... etc
end
```

**Step 2: Update ComplianceScorer**

In `app/services/compliance_scorer.rb`, change from:

```ruby
# OLD
choice = question.answer_choices.find_by(id: answer.answer_value["choice_id"])
```

To:

```ruby
# NEW
choice = answer.answer_choice  # Use association directly
```

**Step 3: Update PrivacyPolicyGenerator**

Similar updates in `app/services/privacy_policy_generator.rb`

**Step 4: Update all tests**

Change test fixtures and assertions to use new fields

**Step 5: Run full test suite**

```bash
bin/rails test
```

Expected: All tests pass

**Step 6: Commit each service separately**

```bash
git add app/controllers/answers_controller.rb test/controllers/answers_controller_test.rb
git commit -m "refactor: use separate answer fields in AnswersController"

git add app/services/compliance_scorer.rb test/services/compliance_scorer_test.rb
git commit -m "refactor: use separate answer fields in ComplianceScorer"

# ... etc
```

---

## Phase 4: Add Database Constraints

### Task 4: Add Check Constraints for Data Integrity

**Files:**
- Create: `db/migrate/[timestamp]_add_answer_field_constraints.rb`

**Step 1: Create constraint migration**

```ruby
class AddAnswerFieldConstraints < ActiveRecord::Migration[8.1]
  def up
    # Ensure exactly one answer field is populated per answer
    # This enforces that each answer uses the correct field for its question type
    execute <<-SQL
      ALTER TABLE answers
      ADD CONSTRAINT exactly_one_answer_field CHECK (
        (
          -- Count how many fields are populated
          (CASE WHEN answer_choice_id IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_text IS NOT NULL AND answer_text != '' THEN 1 ELSE 0 END) +
          (CASE WHEN answer_rating IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_number IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_date IS NOT NULL THEN 1 ELSE 0 END) +
          (CASE WHEN answer_boolean IS NOT NULL THEN 1 ELSE 0 END)
        ) = 1
      )
    SQL

    # Add index for common queries
    add_index :answers, [:question_id, :answer_choice_id],
      where: "answer_choice_id IS NOT NULL",
      name: "index_answers_on_question_and_choice"
  end

  def down
    remove_index :answers, name: "index_answers_on_question_and_choice"
    execute "ALTER TABLE answers DROP CONSTRAINT exactly_one_answer_field"
  end
end
```

**Step 2: Run migration**

```bash
bin/rails db:migrate
```

Expected: Migration succeeds (proves all data is valid)

**Step 3: Test constraint enforcement**

```bash
bin/rails runner "
  # Should fail - no fields populated
  begin
    Answer.create!(response: Response.first, question: Question.first, calculated_score: 0)
    puts '❌ Constraint not working'
  rescue ActiveRecord::StatementInvalid
    puts '✓ Constraint prevents empty answers'
  end

  # Should fail - multiple fields populated
  begin
    Answer.create!(
      response: Response.first,
      question: Question.first,
      answer_text: 'test',
      answer_rating: 5,
      calculated_score: 0
    )
    puts '❌ Constraint not working'
  rescue ActiveRecord::StatementInvalid
    puts '✓ Constraint prevents multiple fields'
  end

  puts '✓ Database constraints working correctly'
"
```

**Step 4: Commit**

```bash
git add db/migrate
git commit -m "feat: add database constraints for answer field integrity"
```

---

## Phase 5: Remove JSONB Field (Dual-Write Ends)

### Task 5: Deprecate and Remove answer_value

**Files:**
- Create: `db/migrate/[timestamp]_remove_answer_value_jsonb.rb`
- Modify: `app/models/answer.rb`

**Step 1: Monitor production for 1-2 weeks**

Verify:
- [ ] All new answers use separate fields
- [ ] No code is reading answer_value
- [ ] Reports work correctly
- [ ] Compliance scoring works correctly
- [ ] Document generation works correctly

**Step 2: Create removal migration**

```ruby
class RemoveAnswerValueJsonb < ActiveRecord::Migration[8.1]
  def up
    # Safety check: ensure all answers have separate fields
    unmigrated = Answer.where(
      answer_choice_id: nil,
      answer_text: nil,
      answer_rating: nil,
      answer_number: nil,
      answer_date: nil,
      answer_boolean: nil
    ).count

    if unmigrated > 0
      raise "Cannot remove answer_value: #{unmigrated} answers not migrated to separate fields"
    end

    remove_column :answers, :answer_value
  end

  def down
    add_column :answers, :answer_value, :jsonb, default: {}, null: false

    # Restore JSONB from separate fields
    Answer.find_each do |answer|
      if answer.answer_choice_id.present?
        answer.update_column(:answer_value, { choice_id: answer.answer_choice_id })
      elsif answer.answer_text.present?
        answer.update_column(:answer_value, { text: answer.answer_text })
      # ... etc
      end
    end
  end
end
```

**Step 3: Remove dual-write logic**

Edit `app/models/answer.rb`:

```ruby
class Answer < ApplicationRecord
  belongs_to :response
  belongs_to :question
  belongs_to :answer_choice, optional: true

  # Remove old validation
  # validates :answer_value, presence: true  # REMOVED

  # Add new validation - at least one field must be populated
  validate :at_least_one_answer_field_present

  after_save :calculate_score

  def answer_choice_text
    answer_choice&.choice_text
  end

  private

  def calculate_score
    return nil unless question.weight.present?
    # Score calculation logic
  end

  def at_least_one_answer_field_present
    if [answer_choice_id, answer_text, answer_rating, answer_number, answer_date].all?(&:blank?) && answer_boolean.nil?
      errors.add(:base, "At least one answer field must be present")
    end
  end

  # REMOVED: sync_to_jsonb, sync_from_jsonb
end
```

**Step 4: Run tests**

```bash
bin/rails test
```

Expected: All tests pass

**Step 5: Deploy to staging, verify, then production**

**Step 6: Run migration in production**

```bash
# On production server
bin/rails db:migrate
```

**Step 7: Commit**

```bash
git add db/migrate app/models/answer.rb
git commit -m "refactor: remove answer_value JSONB, use separate fields only"
```

---

## Rollback Plan

### If Issues Arise During Migration

**During Phase 1-2 (Dual-write active):**
```ruby
# Can roll back migration easily
bin/rails db:rollback
```

**During Phase 3-4 (Code updated but JSONB still exists):**
```ruby
# Revert code changes, keep new fields for future attempt
git revert <commits>
# JSONB still works, new fields unused
```

**After Phase 5 (JSONB removed):**
```ruby
# Use down migration to restore JSONB
bin/rails db:migrate:down VERSION=<timestamp>
```

---

## Verification Checklist

After each phase, verify:

- [ ] All existing answers display correctly
- [ ] New answers save successfully
- [ ] Compliance scoring produces same results
- [ ] Privacy policy generation works
- [ ] AI chat extracts and saves answers
- [ ] Traditional form works
- [ ] Database backups taken
- [ ] No performance degradation

---

## Benefits After Migration

### 1. **Data Integrity**
```ruby
# Before: Silent data corruption possible
Answer.create!(answer_value: { choice_id: 99999 })  # Invalid ID!

# After: Database prevents corruption
Answer.create!(answer_choice_id: 99999)
# => ActiveRecord::InvalidForeignKey ✓
```

### 2. **Query Performance**
```sql
-- Before: Sequential scan, JSONB extraction
SELECT * FROM answers
WHERE answer_value->>'choice_id' = '123';

-- After: Index scan
SELECT * FROM answers
WHERE answer_choice_id = 123;
-- 10-100x faster!
```

### 3. **Type Safety**
```ruby
# Before: No type checking
answer.answer_value["rating"] = "five"  # Wrong type!

# After: PostgreSQL enforces
answer.answer_rating = "five"
# => TypeError ✓
```

### 4. **Clear Semantics**
```ruby
# Before: Unclear if missing or null
answer.answer_value  # => {}  (no answer? or empty?)

# After: Explicit
answer.answer_text  # => nil (clearly no text answer)
```

### 5. **Better Rails Patterns**
```ruby
# Before: Manual lookups
choice = AnswerChoice.find(answer.answer_value["choice_id"])

# After: Standard associations
answer.answer_choice  # Preloadable, joinable, cached
```

---

## Timeline Estimate

- **Phase 1:** 1 day (add fields, dual-write)
- **Phase 2:** 1 day (data migration, testing)
- **Phase 3:** 2-3 days (update all code)
- **Phase 4:** 1 day (add constraints)
- **Phase 5:** 1 day (remove JSONB after monitoring period)
- **Monitoring:** 1-2 weeks between phases

**Total:** 1-2 weeks active work + 2-4 weeks monitoring

---

## Alternative: Keep JSONB But Improve It

If you decide NOT to migrate to separate fields, at least improve the JSONB usage:

### Option A: Standardize JSONB Structure
```ruby
# Always use consistent keys
{ type: "choice", choice_id: 123 }
{ type: "text", text: "..." }
{ type: "rating", rating: 4 }
```

### Option B: Add JSONB Schema Validation
```ruby
class Answer < ApplicationRecord
  validate :answer_value_schema

  private

  def answer_value_schema
    case question.question_type
    when "yes_no"
      unless answer_value.key?("choice_id") && answer_value["choice_id"].is_a?(Integer)
        errors.add(:answer_value, "must have integer choice_id for yes/no questions")
      end
    # ... etc
    end
  end
end
```

---

## My Recommendation

**For Monaco RGPD:** Migrate to separate fields because:

1. **Regulatory compliance** requires audit-proof data
2. **Performance matters** when generating reports for thousands of assessments
3. **Data integrity** is more important than flexibility
4. **Question types are well-defined** (not truly dynamic)
5. **Foreign key constraints** catch bugs before they become compliance issues

The migration is **low risk** with the dual-write approach, and the benefits are **significant** for a compliance SaaS product.

---

## Next Steps

1. Review this plan with stakeholders
2. Schedule migration during low-traffic period
3. Take full database backup
4. Execute Phase 1 in development
5. Test thoroughly before production

Want me to start implementing Phase 1 now, or wait until the AI chat feature is fully validated in production?
