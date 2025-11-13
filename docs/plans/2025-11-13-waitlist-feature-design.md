# Waitlist Feature Design

**Date:** 2025-11-13
**Status:** Validated Design
**Goal:** Build waitlist to collect feature demand and product intelligence while respecting user time investment

## Overview

A two-tier waitlist system that:
- Captures emails from users needing features under development
- Collects rich product intelligence (full questionnaire context) for roadmap prioritization
- Provides partial value to users even when we can't fully support their case
- Handles geographic expansion (Monaco-only currently) and feature-specific needs (Associations, video surveillance, etc.)

## High-Level Architecture

### Core Components

1. **AnswerChoice metadata** - `triggers_waitlist: boolean` flag
   - Marks specific answers requiring features under development
   - Examples: "Association", "Oui" for video surveillance

2. **WaitlistEntry model** - New database table
   - Stores email opt-ins with context
   - Links to full `QuestionnaireResponse` for rich product intelligence

3. **Two flow patterns:**
   - **Immediate exit flow** (Monaco only): Interrupt → Waitlist page → Exit
   - **Completion flow** (all others): Silent flagging → Complete questionnaire → Partial results + Waitlist

4. **Results page logic:**
   - Check if any waitlist-triggering answers selected
   - If yes: Show partial/generic compliance insights + waitlist form
   - If no: Show full assessment as normal

## Database Schema

### AnswerChoice Extension

```ruby
# Migration: add_waitlist_trigger_to_answer_choices
add_column :answer_choices, :triggers_waitlist, :boolean, default: false
add_column :answer_choices, :waitlist_feature_key, :string, null: true
```

**Purpose:**
- `waitlist_feature_key` identifies WHICH feature (e.g., "association", "video_surveillance", "geographic_expansion")
- Enables: grouping entries by feature, custom messaging, roadmap analytics

### WaitlistEntry Model

```ruby
# Migration: create_waitlist_entries
create_table :waitlist_entries do |t|
  t.string :email, null: false
  t.references :questionnaire_response, null: false, foreign_key: true
  t.jsonb :features_needed, default: [], null: false
  # e.g., ["association", "video_surveillance"]

  t.boolean :notified, default: false
  t.datetime :notified_at

  t.timestamps
end

add_index :waitlist_entries, :email
add_index :waitlist_entries, :features_needed, using: :gin
add_index :waitlist_entries, [:notified, :created_at]
```

**Rationale:**
- `features_needed` is jsonb array (one response might trigger multiple features)
- `notified` tracking reserved for future feature launches
- Indexes support: "Find all waiting for Association", "Find un-notified entries"
- Reference to `questionnaire_response` provides ALL questionnaire context

## Detection & Flow Logic

### Waitlist Detection

```ruby
# In QuestionnaireResponse model or service
def waitlist_features_needed
  selected_answers = answers.includes(:answer_choice)

  waitlist_triggers = selected_answers
    .select { |a| a.answer_choice.triggers_waitlist? }
    .map { |a| a.answer_choice.waitlist_feature_key }
    .compact
    .uniq

  waitlist_triggers
end

def requires_waitlist?
  waitlist_features_needed.any?
end
```

### Flow Control

**Immediate Exit (Monaco only):**
- Logic rule on S1Q1 "Non" answer: `action: :exit_to_waitlist`
- New controller action: `QuestionnairesController#waitlist_exit`
- Shows interstitial page with email form
- Creates `WaitlistEntry` with feature: "geographic_expansion"
- Exits - no results page

**Deferred to Results (all others):**
- No interruption during questionnaire
- User submits final answer → `QuestionnaireResponsesController#results`
- Controller checks `@response.requires_waitlist?`
- If true: renders `results_with_waitlist` view (partial results + email form)
- If false: renders normal `results` view

## User Interface

### Page 1: Immediate Exit Waitlist (Monaco only)

**Route:** `/questionnaires/:id/waitlist_exit`

**Content:**
```
[Icon/illustration]

Nous ne couvrons pas encore les organisations hors de Monaco

Nous prévoyons d'étendre nos services à d'autres pays.
Laissez-nous votre email pour être notifié lors de notre expansion géographique.

[Email input field]
[Bouton: "Me notifier"] [Lien: "Non merci"]

Note: Votre session ne sera pas sauvegardée.
```

### Page 2: Results with Waitlist (Completion flow)

**Route:** `/questionnaire_responses/:id/results`

**Content:**
```
Votre évaluation partielle RGPD

[Partial results section showing generic compliance insights]
- Obligations de base identifiées
- Recommandations générales
- Checklist items applicable

[Divider/separator]

⚠️ Évaluation incomplète

Votre cas nécessite [une analyse personnalisée pour la vidéosurveillance /
un cadre spécifique pour les associations / etc.] que nous développons actuellement.

Laissez votre email pour recevoir votre évaluation complète dès que cette
fonctionnalité sera disponible.

[Email input field]
[Bouton: "Recevoir l'évaluation complète"] [Lien: "Terminer sans notification"]
```

## Seed File Configuration

### Marking Waitlist Triggers

**S1Q1 - Monaco question (immediate exit):**
```ruby
s1q1_monaco.answer_choices.create!([
  { order_index: 1, choice_text: "Oui", score: 0 },
  {
    order_index: 2,
    choice_text: "Non",
    score: 0,
    triggers_waitlist: true,
    waitlist_feature_key: "geographic_expansion"
  }
])
```

**S1Q2 - Organization type (deferred):**
```ruby
s1q2_org_type.answer_choices.create!([
  { order_index: 1, choice_text: "Entreprise (...)", score: 0 },
  {
    order_index: 2,
    choice_text: "Association",
    score: 0,
    triggers_waitlist: true,
    waitlist_feature_key: "association"
  },
  {
    order_index: 3,
    choice_text: "Organisme public",
    score: 0,
    triggers_waitlist: true,
    waitlist_feature_key: "organisme_public"
  },
  {
    order_index: 4,
    choice_text: "Profession libérale",
    score: 0,
    triggers_waitlist: true,
    waitlist_feature_key: "profession_liberale"
  }
])
```

**S2Q2 - Video surveillance (deferred):**
```ruby
s2q2_video.answer_choices.create!([
  {
    order_index: 1,
    choice_text: "Oui",
    score: 0,
    triggers_waitlist: true,
    waitlist_feature_key: "video_surveillance"
  },
  { order_index: 2, choice_text: "Non", score: 0 }
])
```

### Logic Rule Update

```ruby
# Keep existing logic rule for Monaco but change action
s1q1_no = s1q1_monaco.answer_choices.find_by(choice_text: "Non")
s1q1_monaco.logic_rules.create!(
  condition_type: :equals,
  condition_value: s1q1_no.id.to_s,
  action: :exit_to_waitlist  # New action type
)

# Remove old exit rules for Association, Organisme public, Profession libérale, Video surveillance
# They now use triggers_waitlist metadata instead
```

## Waitlist Management & Analytics

### Dashboard View 1: Waitlist Overview

```
Feature Demand Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Association:           127 waiting
Video surveillance:     89 waiting
Profession libérale:    64 waiting
Organisme public:       45 waiting
Geographic expansion:   203 waiting
```

### Dashboard View 2: Feature Deep-Dive

Example for "Association":
```
Association Waitlist (127 entries)

Organization Size Breakdown:
- 0 employees:        12
- 1-5 employees:      34
- 6-10 employees:     28
- 11-50 employees:    41
- 50+ employees:      12

Also need (combo triggers):
- Video surveillance: 23
- Website:           89
- Personnel data:    115

Export: [CSV]
```

### Analytics Queries

- "Which feature has most demand?"
- "What's the profile of people waiting for X?"
- "How many would use multiple features?" (combo analysis)
- Segment by organization size, industry, data types, etc.

## Edge Cases & Error Handling

### Multiple Waitlist Triggers
- User selects "Association" AND has video surveillance
- `features_needed: ["association", "video_surveillance"]`
- Results page shows combined message
- Single waitlist entry with multiple features

### Email Already on Waitlist
- Allow duplicate entries (captures updated context/responses over time)
- Shows repeat interest and different contexts

### Skip Email Opt-in
- User clicks "Non merci" / "Terminer sans notification"
- No WaitlistEntry created
- QuestionnaireResponse still saved for anonymous analytics

### Invalid/Spam Emails
- Basic email validation (frontend + backend)
- No email verification (reduce friction)
- Clean spam later from admin dashboard

### Monaco Exit Then Back Button
- User can go back and change answer
- Don't create WaitlistEntry until form submission

## Testing Strategy

### Model Tests

```ruby
# AnswerChoice
- triggers_waitlist flag works correctly
- waitlist_feature_key validation

# QuestionnaireResponse
- #waitlist_features_needed returns correct array
- #requires_waitlist? detects triggers
- Handles multiple triggers correctly

# WaitlistEntry
- Creates with valid data
- Email validation
- features_needed stored as array
- Association to questionnaire_response
```

### Integration/System Tests

```ruby
# Immediate exit flow (Monaco)
- Answer "Non" to Monaco → redirected to waitlist page
- Submit email → creates WaitlistEntry with "geographic_expansion"
- Skip email → no WaitlistEntry created
- Can go back and change answer

# Completion flow (Association, etc.)
- Answer "Association" → continues to all questions
- Submit questionnaire → redirected to results page
- Results page shows partial results + waitlist form
- Submit email → creates WaitlistEntry with "association"
- Correct features_needed for multiple triggers

# Normal flow (no triggers)
- Complete questionnaire with only "Entreprise"
- Results page shows full assessment
- No waitlist form displayed
```

### Manual Testing Checklist

- [ ] UI/UX of both waitlist pages
- [ ] French copy is clear and friendly
- [ ] Email validation feedback
- [ ] Mobile responsive
- [ ] Analytics dashboard queries work

## Implementation Notes

### Features Requiring Waitlist (Current List)

1. **geographic_expansion** - Organizations outside Monaco
2. **association** - Association-specific compliance framework
3. **organisme_public** - Public organization framework
4. **profession_liberale** - Liberal profession framework
5. **video_surveillance** - Personalized video surveillance audit

### Partial Results Content

For completion flow, show generic RGPD guidance:
- Core obligations based on answers
- Basic compliance checklist
- Data inventory requirements
- Consent management for website (if applicable)
- Privacy policy recommendations

### Future Enhancements (Not in Scope)

- Bulk email notification when features launch
- Automated "feature is ready" workflow
- Waitlist entry status management
- Email verification/double opt-in
