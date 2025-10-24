# Introductory Text Feature

## Overview

Questionnaires, sections, and questions can now include optional introductory text to provide context before the main content.

## Usage

### Database Fields

All three models now have an optional `intro_text` field (text):
- `Questionnaire#intro_text` - Shows at questionnaire start
- `Section#intro_text` - Shows at section start
- `Question#intro_text` - Shows before question title

### Markdown Support

Intro text supports basic markdown:
- **Bold** and *italic* text
- Bulleted and numbered lists
- Links: `[text](url)`
- Line breaks

### Visual Design

Intro text appears in a blue-bordered box:
- Light blue background
- Blue left accent border
- Distinct from help_text (which uses yellow/amber Alert style)

### Example

```ruby
Question.create!(
  intro_text: <<~MARKDOWN
    The **Data Protection Officer** (DPO) designation may be:

    - **Mandatory** for certain organizations
    - **Recommended** to demonstrate commitment
    - **Voluntary** in other cases
  MARKDOWN,
  question_text: "Have you designated a Data Protection Officer?",
  help_text: "The DPO can be internal or external to your organization."
)
```

## Components

- `IntroText.svelte` - Reusable component that renders markdown
- Integrated into: QuestionCard, QuestionnaireWizard

## Dependencies

- `marked` - Markdown parser
- `dompurify` - HTML sanitization
- `@tailwindcss/typography` - Prose styling
