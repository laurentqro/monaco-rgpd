# Waitlist System

## Overview

The waitlist system collects emails from users who need features we don't yet support, while providing them partial value from their questionnaire responses.

## Two Flow Types

### Immediate Exit (Geographic Expansion)
- Triggers: Answering "Non" to "Établie à Monaco?"
- Flow: Question → Waitlist page → Exit
- Feature key: `geographic_expansion`

### Completion Flow (Feature-Specific)
- Triggers: Association, Organisme public, Profession libérale, Video surveillance
- Flow: Complete questionnaire → Partial results + Waitlist form
- Feature keys: `association`, `organisme_public`, `profession_liberale`, `video_surveillance`

## Data Model

### WaitlistEntry
- `email`: User's email
- `questionnaire_response_id`: Links to full context
- `features_needed`: Array of feature keys
- `notified`: Boolean for future notification tracking

### AnswerChoice Metadata
- `triggers_waitlist`: Boolean flag
- `waitlist_feature_key`: String identifying the feature

## Admin Dashboard

View waitlist entries at `/admin/waitlist_entries`:
- Feature demand counts
- Recent sign-ups
- Email list for each feature

## Adding New Waitlist Triggers

1. In seed file, mark answer choice:
   ```ruby
   {
     choice_text: "Your choice",
     triggers_waitlist: true,
     waitlist_feature_key: "your_feature_key"
   }
   ```

2. Add feature name mapping in frontend components

3. Test the flow

## Future Enhancements

- Bulk email notifications when features launch
- Automated "feature ready" workflow
- CSV export for email campaigns
- Segmentation by organization size, etc.
