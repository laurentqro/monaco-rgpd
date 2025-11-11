# Manual Testing: Questionnaire Logic Position Handling

## Overview
This document describes the manual testing approach for Task 6: handling invalid positions after logic re-evaluation in the questionnaire wizard.

## Feature Under Test
Safety checks in `handleAnswer` function that handle edge cases when logic re-evaluation changes which questions are visible.

## Test Scenarios

### Scenario 1: Position becomes out of bounds
**Setup:**
1. Create a questionnaire with skip logic (e.g., question that skips to a later section)
2. Navigate to a question in the middle of the questionnaire
3. Answer the question in a way that triggers skip logic, removing questions ahead

**Steps:**
1. Start the questionnaire
2. Navigate to question 5 (for example)
3. Navigate back to question 2
4. Answer question 2 with a value that triggers skip_to_section logic
5. Observe behavior

**Expected Result:**
- Current position should adjust gracefully
- No console errors
- User should be positioned at a valid question
- UI should update smoothly (no flash of invalid state)

### Scenario 2: Current question becomes invisible
**Setup:**
1. Create a questionnaire with skip_to_question logic
2. Position at a question that will be skipped by changing a previous answer

**Steps:**
1. Start the questionnaire
2. Answer questions 1-5 normally
3. Navigate back to question 2
4. Change answer to question 2 to trigger skip_to_question logic
5. Logic should skip questions 3-4
6. Observe behavior if you were at question 3 or 4

**Expected Result:**
- Should navigate to first unanswered question
- If all visible questions answered, should go to last visible question
- No errors in console
- Smooth transition

### Scenario 3: All questions become answered after logic change
**Setup:**
1. Questionnaire where logic change reduces total visible questions
2. All remaining visible questions already answered

**Steps:**
1. Answer all questions in a section
2. Navigate back and change an answer that reduces visible questions
3. Remaining visible questions are already answered

**Expected Result:**
- Should position at last visible question (which is already answered)
- Progress indicator shows 100%
- "Terminer l'évaluation" button is visible
- No console errors

### Scenario 4: Section skip during navigation
**Setup:**
1. Questionnaire with skip_to_section logic
2. User in a section that will be skipped

**Steps:**
1. Navigate to section 2, question 3
2. Navigate back to section 1, question 1
3. Change answer to trigger skip to section 3 (skipping section 2)
4. Observe behavior

**Expected Result:**
- Current position updates to section 3
- Section 2 shows as skipped in tube map
- No errors
- Smooth UI update

## Testing Checklist

- [ ] Test scenario 1: Position out of bounds
- [ ] Test scenario 2: Current question invisible
- [ ] Test scenario 3: All questions answered
- [ ] Test scenario 4: Section skip during navigation
- [ ] Verify no console errors in any scenario
- [ ] Verify tube map updates correctly
- [ ] Verify progress indicator updates correctly
- [ ] Test on desktop (Chrome, Firefox, Safari)
- [ ] Test on mobile (iOS Safari, Chrome Mobile)
- [ ] Verify keyboard navigation still works
- [ ] Verify screen reader announcements

## Browser Testing Matrix

| Browser | Desktop | Mobile | Status |
|---------|---------|--------|--------|
| Chrome  | ✓       | ✓      | [ ]    |
| Firefox | ✓       | -      | [ ]    |
| Safari  | ✓       | ✓      | [ ]    |
| Edge    | ✓       | -      | [ ]    |

## Edge Cases to Verify

1. **Empty visible questions**: Should not crash if logic removes all questions
2. **Rapid answer changes**: Multiple quick answer changes should handle race conditions
3. **Backend save failure**: Position updates should still work if backend save fails
4. **Navigation during save**: Clicking navigation buttons during answer save

## Console Output
Document any console warnings or errors observed during testing.

Expected console output:
- None (all scenarios should run without errors)

## Performance
- Logic re-evaluation should complete within 100ms
- UI updates should be smooth (60fps)
- No visible lag when changing answers

## Accessibility
- Focus management: focus should stay on logical element after position change
- ARIA live regions should announce position changes
- Keyboard navigation should remain consistent

## Notes
- This is defensive programming for edge cases
- Most users won't encounter these scenarios
- Critical for data integrity and user experience
- Prevents JavaScript errors that would break the questionnaire
