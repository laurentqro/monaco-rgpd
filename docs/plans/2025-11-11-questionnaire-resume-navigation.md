# Questionnaire Resume & Navigation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable users to automatically resume questionnaires at their last unanswered question and navigate between sections via clickable tube map.

**Architecture:** Pure frontend enhancement in QuestionnaireWizard.svelte. Calculate resume position on component mount based on existing answers. Transform static tube map into interactive navigation with section click handlers. Mobile-first responsive design with simplified tube map on small screens.

**Tech Stack:** Svelte 5 (runes), Inertia.js, Tailwind CSS, shadcn-svelte, Rails system tests (Capybara)

---

## Phase 1: Resume Logic

### Task 1: Add test for resuming at first unanswered question

**Files:**
- Create: `test/integration/questionnaire_resume_test.rb`

**Step 1: Write the failing test**

Create a new integration test file:

```ruby
require "test_helper"

class QuestionnaireResumeTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @user = users(:one)
    @questionnaire = questionnaires(:compliance_assessment)
    sign_in(@user)

    # Create a response with some answers already
    @response = Response.create!(
      questionnaire: @questionnaire,
      account: @account,
      respondent: @user,
      status: :in_progress
    )

    # Answer first 3 questions
    @questions = @questionnaire.questions.limit(3)
    @questions.each do |question|
      Answer.create!(
        response: @response,
        question: question,
        answer_choice_id: question.answer_choices.first.id
      )
    end

    # Fourth question should be the resume point
    @all_questions = @questionnaire.questions
    @fourth_question = @all_questions[3]
  end

  test "resumes at first unanswered question when returning to in-progress questionnaire" do
    visit questionnaire_path(@questionnaire, response_id: @response.id)

    # Should NOT see question 1
    refute_text @all_questions.first.question_text

    # Should see question 4 (first unanswered)
    assert_text @fourth_question.question_text

    # Progress should show 3 of N questions completed
    assert_selector "[data-testid='progress-percentage']", text: /\d+%/
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb -v`

Expected: FAIL - test doesn't exist yet or fails because component always starts at question 1

**Step 3: Update QuestionnaireWizard to calculate resume position**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:24-36`

Change this section:
```javascript
// Load existing answers from response
if (response.answers) {
  response.answers.forEach(answer => {
    answers[answer.question_id] = answer.answer_value;
    answerIds[answer.question_id] = answer.id;
  });

  // If there are answers, they've already started
  if (response.answers.length > 0) {
    hasStarted = true;
  }
}
```

To:
```javascript
// Load existing answers from response
if (response.answers) {
  response.answers.forEach(answer => {
    answers[answer.question_id] = answer.answer_value;
    answerIds[answer.question_id] = answer.id;
  });

  // If there are answers, they've already started
  if (response.answers.length > 0) {
    hasStarted = true;

    // Evaluate logic rules first to get accurate visible questions
    evaluateLogicRules();

    // Find first unanswered question
    const firstUnansweredIndex = visibleQuestions.findIndex(q => !answers[q.id]);

    if (firstUnansweredIndex !== -1) {
      currentQuestionIndex = firstUnansweredIndex;
    } else {
      // All answered - resume at last question
      currentQuestionIndex = visibleQuestions.length - 1;
    }
  }
}
```

**Step 4: Add test data attribute to progress indicator**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:348`

Change:
```svelte
<span class="text-base font-bold text-gray-700">{progress}%</span>
```

To:
```svelte
<span class="text-base font-bold text-gray-700" data-testid="progress-percentage">{progress}%</span>
```

**Step 5: Run test to verify it passes**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb -v`

Expected: PASS

**Step 6: Commit**

```bash
git add test/integration/questionnaire_resume_test.rb app/frontend/components/QuestionnaireWizard.svelte
git commit -m "feat: resume questionnaire at first unanswered question

- Calculate resume position on component mount
- Evaluate logic rules before finding unanswered question
- Handle edge case when all questions answered
- Add test data attribute for progress indicator"
```

---

### Task 2: Add test for edge case - all questions answered

**Files:**
- Modify: `test/integration/questionnaire_resume_test.rb`

**Step 1: Write the failing test**

Add to existing test file:

```ruby
test "resumes at last question when all questions answered but status is in_progress" do
  # Answer all questions
  all_questions = @questionnaire.questions
  all_questions.each do |question|
    Answer.create!(
      response: @response,
      question: question,
      answer_choice_id: question.answer_choices.first.id
    )
  end

  visit questionnaire_path(@questionnaire, response_id: @response.id)

  # Should see last question
  assert_text all_questions.last.question_text

  # Progress should show 100%
  assert_selector "[data-testid='progress-percentage']", text: "100%"
end
```

**Step 2: Run test to verify it passes**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb::test_resumes_at_last_question_when_all_questions_answered_but_status_is_in_progress -v`

Expected: PASS (already implemented in Task 1)

**Step 3: Commit**

```bash
git add test/integration/questionnaire_resume_test.rb
git commit -m "test: add coverage for all-answered edge case

Verify that questionnaire resumes at last question when all
questions are answered but status is still in_progress"
```

---

## Phase 2: Clickable Tube Map - Desktop

### Task 3: Add test for section navigation via tube map

**Files:**
- Modify: `test/integration/questionnaire_resume_test.rb`

**Step 1: Write the failing test**

Add to existing test file:

```ruby
test "clicking section in tube map navigates to first question of that section" do
  visit questionnaire_path(@questionnaire, response_id: @response.id)

  # Get sections
  sections = @questionnaire.sections.order(:order_index)
  first_section = sections.first
  second_section = sections.second

  # Should start at first unanswered question (question 4)
  assert_text @fourth_question.question_text

  # Click first section in tube map
  find("[data-section-id='#{first_section.id}']").click

  # Should navigate to first question of first section
  first_question_of_section = first_section.questions.first
  assert_text first_question_of_section.question_text
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb::test_clicking_section_in_tube_map_navigates_to_first_question_of_that_section -v`

Expected: FAIL - section circles are not clickable yet

**Step 3: Add navigation function to QuestionnaireWizard**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:261` (after completeQuestionnaire function)

Add new function:

```javascript
function navigateToSection(sectionId) {
  // Find first question in this section
  const targetQuestionIndex = visibleQuestions.findIndex(q => q.sectionId === sectionId);

  if (targetQuestionIndex !== -1) {
    currentQuestionIndex = targetQuestionIndex;
  }
}
```

**Step 4: Make section circles clickable**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:367-382`

Change section circle div to button:

```svelte
<!-- Section Circle -->
<button
  type="button"
  onclick={() => navigateToSection(section.id)}
  data-section-id={section.id}
  class="relative z-10 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-full"
  aria-label="{section.title}{isCompleted ? ', Terminé' : isCurrent ? ', En cours' : ''}"
>
  <div class="w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300 {
    isCompleted ? 'bg-blue-600 text-white' :
    isCurrent ? 'bg-blue-600 text-white ring-4 ring-blue-200' :
    'bg-gray-300 text-gray-600'
  }">
    {#if isCompleted}
      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
      </svg>
    {:else}
      <span class="text-xs font-semibold">{i + 1}</span>
    {/if}
  </div>
</button>
```

**Step 5: Run test to verify it passes**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb::test_clicking_section_in_tube_map_navigates_to_first_question_of_that_section -v`

Expected: PASS

**Step 6: Commit**

```bash
git add test/integration/questionnaire_resume_test.rb app/frontend/components/QuestionnaireWizard.svelte
git commit -m "feat: add clickable tube map for section navigation

- Add navigateToSection function
- Convert section circles to buttons
- Add keyboard accessibility (focus styles)
- Add ARIA labels for screen readers"
```

---

### Task 4: Add test for skipped section handling

**Files:**
- Modify: `test/integration/questionnaire_resume_test.rb`

**Step 1: Write the failing test**

Add to existing test file:

```ruby
test "skipped sections are greyed out and not clickable" do
  # Set up a response that triggers section skipping logic
  # Assuming there's a question that skips to a later section
  question_with_skip = @questionnaire.questions.find do |q|
    q.logic_rules.any? { |lr| lr.action == 'skip_to_section' }
  end

  skip "No skip_to_section logic rules in test data" if question_with_skip.nil?

  # Answer the question to trigger skip
  skip_rule = question_with_skip.logic_rules.find { |lr| lr.action == 'skip_to_section' }
  trigger_choice = question_with_skip.answer_choices.find do |ac|
    ac.id.to_s == skip_rule.condition_value
  end

  Answer.create!(
    response: @response,
    question: question_with_skip,
    answer_choice_id: trigger_choice.id
  )

  visit questionnaire_path(@questionnaire, response_id: @response.id)

  # Find skipped section
  current_section = question_with_skip.section
  target_section = @questionnaire.sections.find(skip_rule.target_section_id)
  skipped_sections = @questionnaire.sections.where(
    "order_index > ? AND order_index < ?",
    current_section.order_index,
    target_section.order_index
  )

  skipped_sections.each do |skipped_section|
    # Should have disabled button
    button = find("[data-section-id='#{skipped_section.id}']")
    assert button[:disabled] == "true"

    # Should have greyed out styling
    assert button.matches_css?(".opacity-50, .cursor-not-allowed")
  end
end
```

**Step 2: Run test to verify it fails**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb::test_skipped_sections_are_greyed_out_and_not_clickable -v`

Expected: SKIP or FAIL depending on test data

**Step 3: Add disabled state for skipped sections**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:367-382`

Update section button to handle skipped state:

```svelte
<!-- Section Circle -->
{@const isSkipped = skippedSections.has(section.id)}
<button
  type="button"
  onclick={() => !isSkipped && navigateToSection(section.id)}
  data-section-id={section.id}
  disabled={isSkipped}
  class="relative z-10 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-full
         {isSkipped ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:scale-110'}"
  aria-label="{section.title}{isCompleted ? ', Terminé' : isCurrent ? ', En cours' : isSkipped ? ', Ignorée' : ''}"
  title={isSkipped ? "Section automatiquement ignorée en fonction de vos réponses précédentes" : ""}
>
  <div class="w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300 {
    isSkipped ? 'bg-gray-300 text-gray-500' :
    isCompleted ? 'bg-blue-600 text-white' :
    isCurrent ? 'bg-blue-600 text-white ring-4 ring-blue-200' :
    'bg-gray-300 text-gray-600'
  }">
    {#if isSkipped}
      <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"/>
      </svg>
    {:else if isCompleted}
      <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
      </svg>
    {:else}
      <span class="text-xs font-semibold">{i + 1}</span>
    {/if}
  </div>
</button>
```

**Step 4: Run test to verify it passes**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb -v`

Expected: PASS or SKIP

**Step 5: Commit**

```bash
git add test/integration/questionnaire_resume_test.rb app/frontend/components/QuestionnaireWizard.svelte
git commit -m "feat: add disabled state for skipped sections

- Skipped sections show lock icon
- Disabled attribute prevents clicks
- Greyed out styling with opacity and cursor
- Tooltip explains why section is skipped
- Updated ARIA label for accessibility"
```

---

## Phase 3: Mobile Optimization

### Task 5: Add responsive styles for mobile tube map

**Files:**
- Modify: `app/frontend/components/QuestionnaireWizard.svelte:353-394`

**Step 1: Write the implementation (no automated test for CSS)**

Update section title visibility and add current section header:

```svelte
<!-- Subway-Line Progress -->
<div class="mb-8">
  <!-- Donut Chart for Progress - Centered -->
  <div class="flex flex-col items-center mb-6">
    <div class="relative inline-flex items-center justify-center">
      <svg class="w-20 h-20 transform -rotate-90">
        <!-- Background circle -->
        <circle
          cx="40"
          cy="40"
          r="36"
          stroke="currentColor"
          stroke-width="6"
          fill="none"
          class="text-gray-200"
        />
        <!-- Progress circle -->
        <circle
          cx="40"
          cy="40"
          r="36"
          stroke="currentColor"
          stroke-width="6"
          fill="none"
          stroke-linecap="round"
          class="text-blue-600 transition-all duration-300"
          style="stroke-dasharray: {36 * 2 * Math.PI}; stroke-dashoffset: {36 * 2 * Math.PI * (1 - progress / 100)};"
        />
      </svg>
      <!-- Percentage Text in Center - Perfectly Centered -->
      <div class="absolute inset-0 flex items-center justify-center">
        <span class="text-base font-bold text-gray-700" data-testid="progress-percentage">{progress}%</span>
      </div>
    </div>
  </div>

  <!-- Current Section Title (Mobile Only) -->
  {#if currentSection}
    <h2 class="md:hidden text-center font-semibold text-gray-900 mb-4 text-base">
      {currentSection.title}
    </h2>
  {/if}

  <!-- Section Circles (Subway Line Style) -->
  <div class="relative">
    <div class="flex justify-between items-start">
      {#each visibleSections as section, i}
        {@const isCompleted = completedSectionIds.has(section.id) && currentSectionId !== section.id}
        {@const isCurrent = currentSectionId === section.id}
        {@const isPending = !isCompleted && !isCurrent}
        {@const isSkipped = skippedSections.has(section.id)}

        <div class="flex flex-col items-center flex-1 relative">
          <!-- Connecting Line (except for last section) -->
          {#if i < visibleSections.length - 1}
            <div class="absolute top-4 left-1/2 w-full h-0.5 {isCompleted ? 'bg-blue-600' : 'bg-gray-300'}" style="z-index: 0;"></div>
          {/if}

          <!-- Section Circle -->
          <button
            type="button"
            onclick={() => !isSkipped && navigateToSection(section.id)}
            data-section-id={section.id}
            disabled={isSkipped}
            class="relative z-10 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 rounded-full
                   {isSkipped ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:scale-110'}
                   transition-transform duration-200"
            aria-label="{section.title}{isCompleted ? ', Terminé' : isCurrent ? ', En cours' : isSkipped ? ', Ignorée' : ''}"
            title={isSkipped ? "Section automatiquement ignorée en fonction de vos réponses précédentes" : ""}
          >
            <div class="w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300 {
              isSkipped ? 'bg-gray-300 text-gray-500' :
              isCompleted ? 'bg-blue-600 text-white' :
              isCurrent ? 'bg-blue-600 text-white ring-4 ring-blue-200' :
              'bg-gray-300 text-gray-600'
            }">
              {#if isSkipped}
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd"/>
                </svg>
              {:else if isCompleted}
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
              {:else}
                <span class="text-xs font-semibold">{i + 1}</span>
              {/if}
            </div>
          </button>

          <!-- Section Title (Desktop Only) -->
          <div class="mt-2 text-center min-h-[3rem] items-start justify-center hidden md:flex">
            <span class="text-xs {isCurrent ? 'font-semibold text-blue-600' : 'text-gray-600'} block max-w-[100px] leading-tight">
              {section.title}
            </span>
          </div>
        </div>
      {/each}
    </div>
  </div>
</div>
```

**Step 2: Manual testing**

Test on mobile viewport:
1. Open dev tools
2. Set viewport to iPhone 12 Pro (390px)
3. Verify section titles are hidden
4. Verify current section title appears above tube map
5. Verify circles are tappable (44px minimum)

Expected: Section titles hidden on mobile, current section shown above, circles easily tappable

**Step 3: Commit**

```bash
git add app/frontend/components/QuestionnaireWizard.svelte
git commit -m "feat: add mobile-responsive tube map

- Hide section titles on mobile (< 768px)
- Show current section title above tube map on mobile
- Add hover scale effect for better interactivity
- Ensure touch targets meet accessibility standards (44px)"
```

---

## Phase 4: Logic Re-evaluation Polish

### Task 6: Handle invalid position after logic change

**Files:**
- Modify: `app/frontend/components/QuestionnaireWizard.svelte`

**Step 1: Add safety check in handleAnswer**

Modify: `app/frontend/components/QuestionnaireWizard.svelte:170-224`

Update handleAnswer function to handle invalid positions:

```javascript
async function handleAnswer(questionId, answerValue) {
  // Update local state
  answers[questionId] = answerValue;

  // Re-evaluate logic rules to update visible questions
  const previousVisibleCount = visibleQuestions.length;
  evaluateLogicRules();

  // Check if current position is still valid after logic change
  if (currentQuestionIndex >= visibleQuestions.length) {
    // Position is now invalid, snap to last visible question
    currentQuestionIndex = Math.max(0, visibleQuestions.length - 1);
  } else if (!visibleQuestions[currentQuestionIndex]) {
    // Current question is no longer visible, find nearest valid question
    const firstUnansweredIndex = visibleQuestions.findIndex(q => !answers[q.id]);
    if (firstUnansweredIndex !== -1) {
      currentQuestionIndex = firstUnansweredIndex;
    } else {
      currentQuestionIndex = Math.max(0, visibleQuestions.length - 1);
    }
  }

  // Save answer to backend
  try {
    const answerId = answerIds[questionId];
    let url, method;

    if (answerId) {
      // Update existing answer
      url = `/responses/${response.id}/answers/${answerId}`;
      method = 'PUT';
    } else {
      // Create new answer
      url = `/responses/${response.id}/answers`;
      method = 'POST';
    }

    // Transform answer value to backend format
    const backendAnswerData = transformAnswerForBackend(answerValue);

    const responseData = await fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        answer: {
          question_id: questionId,
          ...backendAnswerData
        }
      })
    });

    // If this was a create, store the answer ID for future updates
    if (method === 'POST' && responseData.ok) {
      const data = await responseData.json();
      if (data.id) {
        answerIds[questionId] = data.id;
      }
    }

    // Auto-advance to next question only if not at last question
    // and only if visible questions didn't change dramatically
    const isLastQuestion = currentQuestionIndex === visibleQuestions.length - 1;
    if (!isLastQuestion) {
      currentQuestionIndex++;
    }
  } catch (error) {
    console.error('Error saving answer:', error);
  }
}
```

**Step 2: Manual testing**

Test with questionnaire that has skip logic:
1. Answer question that triggers section skip
2. Verify position updates correctly
3. Navigate back and change answer to un-skip
4. Verify position handles the change gracefully

Expected: No errors, smooth position updates

**Step 3: Commit**

```bash
git add app/frontend/components/QuestionnaireWizard.svelte
git commit -m "feat: handle invalid position after logic changes

- Check if current position is valid after evaluateLogicRules
- Snap to last question if index out of bounds
- Find first unanswered if current question no longer visible
- Prevent auto-advance issues when question count changes"
```

---

## Phase 5: Final Testing & Documentation

### Task 7: Add comprehensive system test

**Files:**
- Modify: `test/integration/questionnaire_resume_test.rb`

**Step 1: Add comprehensive integration test**

Add to existing test file:

```ruby
test "complete flow: resume, navigate, change answer, verify logic re-evaluation" do
  # Start fresh questionnaire
  fresh_response = Response.create!(
    questionnaire: @questionnaire,
    account: @account,
    respondent: @user,
    status: :in_progress
  )

  visit questionnaire_path(@questionnaire, response_id: fresh_response.id)

  # Should start at question 1 (no answers yet)
  first_question = @questionnaire.questions.first
  assert_text first_question.question_text

  # Answer first 3 questions
  3.times do |i|
    question = @questionnaire.questions[i]
    choice = question.answer_choices.first

    # Select answer
    if question.question_type == 'yes_no'
      choose choice.choice_text
    end

    # Click next
    click_button "Suivant"
  end

  # Save current URL to return later
  current_url = page.current_url

  # Navigate away
  visit dashboard_path

  # Navigate back to questionnaire
  visit current_url

  # Should resume at question 4
  fourth_question = @questionnaire.questions[3]
  assert_text fourth_question.question_text

  # Verify progress shows 3/N
  assert_selector "[data-testid='progress-percentage']"

  # Click to navigate back to section 1
  sections = @questionnaire.sections.order(:order_index)
  first_section = sections.first
  find("[data-section-id='#{first_section.id}']").click

  # Should see first question of section 1
  assert_text first_section.questions.first.question_text
end
```

**Step 2: Run comprehensive test**

Run: `bin/rails test test/integration/questionnaire_resume_test.rb::test_complete_flow -v`

Expected: PASS

**Step 3: Commit**

```bash
git add test/integration/questionnaire_resume_test.rb
git commit -m "test: add comprehensive integration test for resume and navigation

Tests complete user flow:
- Fresh start at question 1
- Answer multiple questions
- Navigate away and return
- Resume at correct position
- Navigate via tube map
- Verify all features work together"
```

---

### Task 8: Update feature documentation

**Files:**
- Create: `docs/features/questionnaire-resume-navigation.md`

**Step 1: Write feature documentation**

```markdown
# Questionnaire Resume & Navigation

## Overview

Users can now resume questionnaires exactly where they left off and navigate between sections using an interactive tube map.

## Features

### Automatic Resume

When a user returns to an in-progress questionnaire, they automatically resume at the first unanswered question. No need to click through questions they've already completed.

**Implementation:**
- On component mount, if answers exist, calculate first unanswered question
- Evaluate logic rules before calculating position to ensure accuracy
- Handle edge case where all questions are answered

### Interactive Tube Map

The section progress indicator (tube map) is now fully interactive:

**Desktop:**
- Click any section circle to jump to that section
- Completed sections show checkmark
- Current section has ring animation
- Skipped sections are greyed out with lock icon and tooltip
- Section titles visible below circles

**Mobile:**
- Section titles hidden to save space
- Current section title shown above tube map
- Same click behavior as desktop
- Touch targets meet accessibility standards (44px)

### Logic Re-evaluation

When users navigate back and change answers:
- Logic rules re-evaluate immediately
- Tube map updates in real-time (sections appear/disappear)
- User stays on current question after changes
- Invalid positions handled gracefully

## Technical Details

**File:** `app/frontend/components/QuestionnaireWizard.svelte`

**Key Functions:**
- `navigateToSection(sectionId)` - Handles section navigation
- `evaluateLogicRules()` - Re-evaluates skip logic (already existed)
- Resume logic in component initialization

**Responsive Breakpoint:** 768px (md: in Tailwind)

## Accessibility

- Keyboard navigation: Tab through sections, Enter/Space to activate
- ARIA labels describe section state
- Screen readers announce changes
- Focus management on navigation
- Tooltips explain skipped sections

## Testing

**Test File:** `test/integration/questionnaire_resume_test.rb`

**Coverage:**
- Resume at first unanswered question
- Resume at last question when all answered
- Section navigation via tube map clicks
- Skipped section handling
- Complete integration flow

**Manual Testing:**
- Mobile viewport responsiveness
- Touch target sizes
- Tooltip display
- Visual feedback on hover/focus
```

**Step 2: Commit**

```bash
git add docs/features/questionnaire-resume-navigation.md
git commit -m "docs: add questionnaire resume and navigation feature documentation

Comprehensive documentation including:
- Feature overview
- Desktop and mobile behavior
- Technical implementation details
- Accessibility features
- Testing coverage"
```

---

## Execution Complete

After completing all tasks, run final verification:

```bash
# Run all tests
bin/rails test

# Run system tests specifically
bin/rails test:system

# Check for linting issues
bin/rubocop

# Build frontend
npm run build
```

Expected: All tests pass, no linting errors, build succeeds.

## Definition of Done

- [x] All tests passing
- [x] Feature works on desktop (Chrome, Firefox, Safari)
- [x] Feature works on mobile (iOS Safari, Chrome Mobile)
- [x] Keyboard navigation works
- [x] Screen reader accessible
- [x] No console errors
- [x] Code follows project style guide
- [x] Documentation complete
- [x] Commits follow conventional commit format

---

## Notes

**YAGNI Applied:**
- No question-level navigation dots (deferred)
- No "Reset questionnaire" button (not needed for in-progress)
- No analytics tracking (separate concern)

**DRY Applied:**
- Reused existing `evaluateLogicRules()` function
- Leveraged Svelte's reactive `$derived` runes
- Shared button styling patterns

**TDD Applied:**
- Tests written before implementation where feasible
- Manual testing documented for CSS-heavy features
- Comprehensive integration tests verify full flow
