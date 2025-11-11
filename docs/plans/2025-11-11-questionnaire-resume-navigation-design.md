# Questionnaire Resume & Navigation Design

**Date:** 2025-11-11
**Status:** Approved
**Context:** Improve questionnaire UX with automatic resume and interactive navigation

## Overview

Transform the questionnaire experience from "always start at question 1" to "pick up exactly where you left off" with intuitive section-based navigation. This addresses a critical UX gap where users must restart from the beginning even when their answers are already saved.

## Goals

1. **Automatic Resume:** Users return to the first unanswered question, not question 1
2. **Interactive Navigation:** Clickable tube map for jumping between sections
3. **Real-time Logic:** Answer changes immediately update visible sections
4. **Mobile Optimized:** Simplified tube map for small screens
5. **Zero Backend Changes:** Pure frontend enhancement using existing data

## User Experience Flow

### Returning to In-Progress Questionnaire

When a user returns to an in-progress questionnaire:
- System calculates position based on existing answers
- Resumes at first unanswered question automatically
- Progress indicator reflects actual completion (e.g., 22% if 10/45 questions answered)
- No "start from beginning" friction

### Section Navigation

The tube map becomes interactive:
- **Completed sections:** Blue with checkmark, clickable
- **Current section:** Blue with ring animation, clickable
- **Pending sections:** Grey numbered circle, clickable
- **Skipped sections:** Grey with lock icon, NOT clickable, tooltip explains why

### Answer Changes & Logic Re-evaluation

When users navigate back and change answers:
- Logic rules re-evaluate immediately
- Tube map updates in real-time (sections appear/disappear)
- User stays on the question they just edited
- Can continue forward or use tube map to navigate elsewhere
- No disruptive warnings (visual feedback is the warning)

## Technical Implementation

### Resume Logic

**Location:** `app/frontend/components/QuestionnaireWizard.svelte`

**Algorithm:**
1. Load existing answers from response
2. Run `evaluateLogicRules()` to determine visible questions based on saved answers
3. Find first unanswered question in `visibleQuestions` array
4. Set `currentQuestionIndex` to that position
5. If all questions answered but status is `in_progress`, resume at last question

**Code:**
```javascript
// After loading existing answers
if (response.answers.length > 0) {
  hasStarted = true;

  // Evaluate logic first to get accurate visible questions
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
```

### Clickable Tube Map

**Desktop (≥768px):**
- Each section circle is a `<button>` element
- Section titles displayed below circles
- Three states: completed, current, pending, skipped
- Hover tooltips:
  - Completed: "Terminé"
  - Current: Section title
  - Skipped: "Section automatiquement ignorée en fonction de vos réponses précédentes"
- Keyboard accessible (Tab, Enter/Space)

**Mobile (<768px):**
- Section titles hidden
- Only numbered circles (or checkmarks for completed)
- Current section title displayed as heading above tube map
- Same click behavior and states
- Touch targets minimum 44px

**Navigation function:**
```javascript
function navigateToSection(sectionId) {
  // Find first question in this section
  const targetQuestionIndex = visibleQuestions.findIndex(q => q.sectionId === sectionId);

  if (targetQuestionIndex !== -1) {
    currentQuestionIndex = targetQuestionIndex;
  }
}
```

**Skipped section UI:**
- Grey circle with lock icon (🔒)
- `disabled` attribute on button
- `cursor: not-allowed`
- Tooltip explains why skipped
- Maintains position in tube map for full structure visibility

### Logic Re-evaluation

Already handled by Svelte reactivity:
- `visibleQuestions` is a `$derived` rune
- Automatically recalculates when `answers` or `skippedSections` change
- `evaluateLogicRules()` runs in `handleAnswer()` on every answer change
- Tube map reactively updates based on `visibleQuestions` and `skippedSections`

## Edge Cases

### Invalid Position After Logic Change

If user is on question 30 but changing an earlier answer causes questions 20-40 to be skipped:
- Detect invalid position (current question no longer in `visibleQuestions`)
- Snap to nearest valid question (first unanswered or last question in current section)

### Section Skipping Transparency

Users need to understand why sections are skipped:
- Show skipped sections (don't hide them)
- Clear visual distinction (grey + lock icon)
- Explanatory tooltip on hover
- Builds trust in compliance context

### Navigation Scope

Navigation is ONLY available for in-progress questionnaires:
- Completed questionnaires are view-only
- No editing or navigation on completed responses
- Simplifies logic and prevents data integrity issues

## Accessibility

- **ARIA labels:** `aria-label="Section 1: Données personnelles, Terminé"`
- **Keyboard navigation:** Tab through sections, Enter/Space to activate
- **Screen readers:** Announce progress changes and section states
- **Focus management:** Focus moves to question card after navigation
- **Touch targets:** Minimum 44px for mobile
- **Color independence:** Icons (checkmark, lock) supplement color coding

## Testing Strategy

### Resume Functionality
- [ ] Fresh start (no answers) → begins at question 1
- [ ] Partial completion (10/45 answered) → resumes at question 11
- [ ] All answered, in_progress status → resumes at last question

### Navigation
- [ ] Click completed section → jumps to first question of that section
- [ ] Click current section → stays on current question (or jumps to first)
- [ ] Click pending section → jumps to first question
- [ ] Skipped sections are disabled and not clickable
- [ ] Keyboard navigation works (Tab, Enter, Space)

### Logic Re-evaluation
- [ ] Change answer that skips sections → tube map updates, sections grey out
- [ ] Change answer that reveals sections → tube map updates, sections appear
- [ ] Navigation after logic changes → lands at valid question
- [ ] Invalid position handled gracefully

### Mobile Responsiveness
- [ ] Tube map shows only circles on mobile (<768px)
- [ ] Current section title displayed above tube map
- [ ] Touch targets are 44px minimum
- [ ] Scrolling works smoothly
- [ ] No horizontal overflow

## Implementation Phases

**Phase 1: Resume Logic (1-2 hours)**
- Calculate first unanswered position on component load
- Handle edge cases (all answered, no answers)
- Test with various answer states

**Phase 2: Clickable Tube Map - Desktop (2-3 hours)**
- Convert section circles to buttons
- Add click handlers and navigation function
- Implement tooltips
- Add keyboard accessibility
- Handle skipped sections (disabled state)

**Phase 3: Mobile Optimization (1-2 hours)**
- Hide section titles on mobile
- Show current section title above tube map
- Ensure touch targets meet accessibility standards
- Test on various mobile devices/viewports

**Phase 4: Logic Re-evaluation Polish (1 hour)**
- Handle invalid position after logic changes
- Test dynamic section appearance/disappearance
- Visual feedback verification

## Backend Changes

**None required.** This is a pure frontend enhancement:
- Response model already tracks `in_progress` status ✓
- Answers are already auto-saved ✓
- Controller already sends existing answers ✓
- Logic rules already defined in Question model ✓

## Success Metrics

- Users can return and resume without confusion
- Navigation between sections is intuitive
- Logic changes provide clear visual feedback
- Mobile experience is smooth and accessible
- Zero regression in existing questionnaire functionality

## Future Enhancements

Deferred for later consideration:
- Question-level navigation (expandable section view)
- "Reset questionnaire" functionality for completed responses
- Progress persistence across sessions with visual "You were here" indicator
- Analytics on navigation patterns
