# Questionnaire Layout Optimization Design

**Date:** 2025-11-11
**Status:** Approved
**Context:** Reduce excessive whitespace around questionnaire area to better utilize screen real estate

## Problem Statement

The questionnaire currently uses only ~35% of available screen width on standard desktop displays (1920px), with a `max-w-2xl` (672px) container. This creates excessive blank space that makes the interface feel cramped despite ample available space.

## Goals

1. **Better space utilization** - Increase usable width to ~47% on large displays
2. **Maintain readability** - Stay within optimal reading width (600-1000px) for form content
3. **Vertical space optimization** - Reduce padding to fit more content on screen
4. **No breaking changes** - Pure CSS update with no logic changes

## Solution: Balanced Width Increase

### Container Changes

**Current State:**
```svelte
<div class="max-w-2xl mx-auto p-6">
```
- Max width: 672px (Tailwind's `max-w-2xl`)
- Padding: 24px all sides

**Proposed State:**
```svelte
<div class="max-w-4xl mx-auto p-4">
```
- Max width: 896px (Tailwind's `max-w-4xl`)
- Padding: 16px all sides

### Impact Analysis

**Width:**
- Increase: +224px (33% wider)
- Screen usage on 1920px display: 35% → 47%
- Still within optimal reading width for forms (600-1000px)

**Vertical Space:**
- Reduction: 8px top + 8px bottom = 16px gained per screen
- More content visible without scrolling
- Maintains comfortable spacing

**Readability:**
- 896px is optimal for form-based content
- Wider than articles (600-700px ideal) but appropriate for questionnaires
- Question cards, buttons, and inputs have room to breathe

## Implementation

### File Changes

**Single file modification:**
- File: `app/frontend/components/QuestionnaireWizard.svelte`
- Line: 321
- Change: `max-w-2xl mx-auto p-6` → `max-w-4xl mx-auto p-4`

### Testing Strategy

**Manual Visual Testing:**

1. **Desktop (1920x1080)**
   - Verify ~900px width feels spacious
   - Check all question types render properly
   - Confirm tube map scales well
   - Test button layouts

2. **Laptop (1440x900, 1366x768)**
   - Verify content doesn't feel too wide
   - Check padding doesn't make content cramped
   - Test readability with long text

3. **Tablet (768px)**
   - Ensure mobile breakpoints work (md: prefix)
   - Verify padding works on smaller screens

4. **Content Scenarios**
   - Long question text
   - Many answer choices
   - Intro text at wider width
   - Tube map with 5-7 sections

### Rollback Options

If wider layout doesn't feel right:

**Option 1: Middle ground**
- Use `max-w-3xl` (768px) instead of `max-w-4xl`

**Option 2: Keep padding**
- Change width but keep `p-6` instead of `p-4`

**Option 3: Responsive tiers**
- `max-w-3xl lg:max-w-4xl` for granular control

## Technical Details

**Tailwind Classes:**
- `max-w-4xl` = `max-width: 56rem` = `896px`
- `p-4` = `padding: 1rem` = `16px`

**No Component Logic Changes:**
- Pure CSS/Tailwind update
- No JavaScript modifications
- No Svelte reactivity affected
- Existing tests will pass unchanged

**Browser Compatibility:**
- Standard CSS max-width and padding
- Full compatibility with all modern browsers
- No new dependencies

## Alternatives Considered

**Alternative 1: Extra-large container (max-w-5xl or max-w-6xl)**
- Pros: Maximum space utilization
- Cons: Too wide (1024-1152px), might feel stretched, harder to focus
- Decision: Rejected - too wide for optimal form UX

**Alternative 2: Custom responsive widths**
- Pros: Adapts perfectly to each screen size
- Cons: More complex, harder to maintain, over-engineering for simple fix
- Decision: Rejected - YAGNI, can add later if needed

**Alternative 3: Keep narrow, optimize vertical only**
- Pros: Minimal change, safe
- Cons: Doesn't address the primary complaint (horizontal whitespace)
- Decision: Rejected - doesn't solve the core problem

## Success Criteria

- ✅ Questionnaire feels more spacious on desktop
- ✅ No horizontal scrolling on any viewport
- ✅ Text remains readable (not too wide)
- ✅ All existing functionality works
- ✅ All tests pass
- ✅ No visual regressions

## Future Enhancements

**Deferred (YAGNI):**
- Dynamic width based on question type
- User preference for compact/spacious layout
- Different widths for different questionnaire sections
- Advanced responsive breakpoints

## Commit Strategy

**Single commit:**
```
refactor: optimize questionnaire layout for better space utilization

- Increase max width from 672px to 896px (max-w-4xl)
- Reduce padding from 24px to 16px for more vertical space
- Improves screen real estate usage while maintaining readability
```

## Risk Assessment

**Risk Level:** Low

**Risks:**
- Content might feel too wide on some screens → Mitigated by staying within 600-1000px optimal range
- Padding reduction might feel cramped → Mitigated by testing, easy to revert
- Mobile layout might break → Mitigated by existing responsive classes (md:)

**Confidence:** High - simple CSS change, easy to test, easy to adjust
