# Skip-to-Question Logic Rules Implementation Plan

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Add support for `skip_to_question` action in logic rules and refactor seed file to use pure logic rules without Ruby conditionals.

**Architecture:** Extend the LogicRule model to support both section-level and question-level targeting. Add a new `skip_to_question` action enum value and a `target_question_id` column. Refactor the seed file to define all questions first, then add all logic rules declaratively without Ruby if/else blocks.

**Tech Stack:** Rails 8, PostgreSQL, ActiveRecord migrations

---

### Task 1: Add target_question_id column to logic_rules

**Files:**
- Create: `db/migrate/20251017XXXXXX_add_target_question_to_logic_rules.rb`
- Modify: `app/models/logic_rule.rb:2-4`

**Step 1: Create the migration**

```bash
bin/rails generate migration AddTargetQuestionToLogicRules target_question_id:references
```

**Step 2: Edit the migration to make it optional and add index**

```ruby
class AddTargetQuestionToLogicRules < ActiveRecord::Migration[8.0]
  def change
    add_reference :logic_rules, :target_question, foreign_key: { to_table: :questions }, index: true
  end
end
```

**Step 3: Run the migration**

```bash
bin/rails db:migrate
```

Expected: Migration runs successfully, adds target_question_id column

**Step 4: Update the LogicRule model**

In `app/models/logic_rule.rb`, after line 3, add:

```ruby
  belongs_to :target_question, class_name: "Question", optional: true
```

**Step 5: Commit**

```bash
git add db/migrate/*add_target_question_to_logic_rules.rb app/models/logic_rule.rb db/schema.rb
git commit -m "feat: add target_question_id to logic_rules

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: Add skip_to_question action to LogicRule enum

**Files:**
- Modify: `app/models/logic_rule.rb:13-18`

**Step 1: Add skip_to_question to action enum**

In `app/models/logic_rule.rb`, update the action enum (lines 13-18):

```ruby
  enum :action, {
    show: 0,
    hide: 1,
    skip_to_section: 2,
    exit_questionnaire: 3,
    skip_to_question: 4
  }, prefix: true
```

**Step 2: Verify in Rails console**

```bash
bin/rails console
```

```ruby
LogicRule.actions
# Should output: {"show"=>0, "hide"=>1, "skip_to_section"=>2, "exit_questionnaire"=>3, "skip_to_question"=>4}
exit
```

Expected: New action appears in enum hash

**Step 3: Commit**

```bash
git add app/models/logic_rule.rb
git commit -m "feat: add skip_to_question action to LogicRule

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: Refactor seed file to use pure logic rules

**Files:**
- Modify: `db/seeds/master_questionnaire.rb:1-410`

**Step 1: Remove all Ruby conditionals and logic rule creation from question definitions**

Remove all blocks like:

```ruby
# Add exit logic rule: if not in Monaco, exit questionnaire
no_monaco_choice = monaco_question.answer_choices.find_by(choice_text: "Non")
if monaco_question && no_monaco_choice
  monaco_question.logic_rules.find_or_create_by!(
    condition_type: :equals,
    condition_value: no_monaco_choice.id.to_s,
    action: :exit_questionnaire,
    exit_message: "..."
  )
end
```

**Step 2: Add a dedicated "Logic Rules" section at the end**

At the end of the file (after all questions are created, before the `puts` statements), add:

```ruby
# ============================================================================
# Logic Rules Configuration
# ============================================================================
# All logic rules are defined here after all questions are created
# This ensures all question IDs are available for targeting

# Rule 1: Exit if not in Monaco
monaco_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: monaco_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :exit_questionnaire,
  exit_message: "Nous ne couvrons que Monaco pour le moment, mais laissez votre email et on vous contactera quand nous couvrirons d'autres pays que Monaco."
)

# Rule 2: Exit if no personal data processing
personal_data_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: personal_data_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :exit_questionnaire,
  exit_message: "Si vous ne traitez pas de données personnelles, vous n'êtes pas concerné par les obligations RGPD pour le moment."
)

# Rule 3: Skip HR section if no personnel
has_personnel_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_personnel_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_section,
  target_section_id: section4_dpo.id
)

# Rule 4: Skip email subsection if no professional email
has_email_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_email_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: has_phone_question.id
)

# Rule 5: Skip phone subsection if no direct line
has_phone_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_phone_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: access_method_question.id
)

# Rule 6: Skip delegates subsection if no delegates
has_delegates_question.logic_rules.find_or_create_by!(
  condition_type: :equals,
  condition_value: has_delegates_question.answer_choices.find_by(choice_text: "Non").id.to_s,
  action: :skip_to_question,
  target_question_id: hr_purposes_question.id
)
```

**Step 3: Test seed file**

```bash
bin/rails db:seed:replant
```

Expected: Seeds run without errors, all logic rules created

**Step 4: Verify in Rails console**

```bash
bin/rails console
```

```ruby
q = Questionnaire.last
q.sections.count  # Should be 5
q.questions.count  # Should be appropriate number
LogicRule.count  # Should be 6

# Check skip_to_question rules
LogicRule.where(action: :skip_to_question).count  # Should be 3
LogicRule.where(action: :skip_to_question).pluck(:target_question_id).compact.count  # Should be 3
exit
```

Expected: All counts match, no nil target_question_ids for skip_to_question rules

**Step 5: Commit**

```bash
git add db/seeds/master_questionnaire.rb
git commit -m "refactor: use pure logic rules in seed file

Remove Ruby conditionals and consolidate all logic rule
creation in a dedicated section at the end of the seed file.

This makes the questionnaire structure more declarative and
easier to understand.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: Update questionnaire navigation logic (if needed)

**Files:**
- Check: `app/controllers/questionnaires_controller.rb` or similar
- Check: `app/models/response.rb` or questionnaire service objects

**Step 1: Find questionnaire navigation code**

```bash
grep -r "skip_to_section" app/
grep -r "LogicRule" app/controllers/
grep -r "next_question" app/
```

**Step 2: If navigation code exists, update it to handle skip_to_question**

Look for code that evaluates logic rules and handles navigation. Add handling for the new `skip_to_question` action:

```ruby
case logic_rule.action
when "skip_to_section"
  # existing code
when "skip_to_question"
  return logic_rule.target_question
when "exit_questionnaire"
  # existing code
end
```

**Step 3: If no navigation code exists yet, document TODO**

Add a comment in the seed file or create a follow-up issue:

```ruby
# TODO: Implement questionnaire navigation logic that respects:
#   - skip_to_section: jumps to target_section
#   - skip_to_question: jumps to target_question
#   - exit_questionnaire: stops questionnaire with message
```

**Step 4: Commit if changes made**

```bash
git add app/controllers/* app/models/*
git commit -m "feat: handle skip_to_question in navigation logic

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Testing Checklist

- [ ] Migration runs cleanly
- [ ] Seeds run without errors
- [ ] All 6 logic rules created correctly
- [ ] skip_to_question rules have non-null target_question_id
- [ ] Questionnaire structure matches specification
- [ ] No Ruby conditionals remain in seed file (except `.tap` blocks)

## Notes

- The seed file should be completely declarative after this refactor
- All logic rules are defined in one place for easy maintenance
- The `target_question_id` and `target_section_id` are mutually exclusive based on action type
- Future logic rules can be added to the dedicated section without touching question definitions
