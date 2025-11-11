# Compliance Dashboard Design

**Date:** 2025-11-11
**Status:** Approved
**Context:** Transform dashboard from assessment display into active compliance command center

## Overview

The compliance dashboard transforms Monaco RGPD from "assessment tool" into "active compliance command center" by surfacing urgent items, recommended actions, and health metrics in a priority-driven vertical flow. Users can manage regulatory deadlines (data breaches, subject access requests), execute assessment-driven recommendations via guided workflows, and monitor compliance health across all areas.

## Goals

1. **Current Status Focus:** Highlight active compliance tasks, upcoming deadlines, and items requiring attention
2. **Action-Oriented:** Quick access to generate/update documents, manage incidents, and initiate assessments with minimal clicks
3. **Compliance Health Visibility:** Visual breakdown showing which compliance areas are strong vs weak, with direct links to improvement resources
4. **Historical Intelligence:** Track compliance score evolution and identify trends over time

## Priorities (User-Validated)

In order of importance:
1. Current status focus (A)
2. Action-oriented overview (C)
3. Compliance health snapshot (D)
4. Historical trends (B)

## Dashboard Layout

Priority-driven vertical flow with components ordered by urgency:

```
┌─────────────────────────────────────────┐
│ Action Items Inbox                      │ ← Critical/High/Medium/Low prioritized
│ (Unified regulatory + recommendations)  │
├─────────────────────────────────────────┤
│ Quick Actions Panel                     │ ← Common tasks (new assessment, generate docs)
├─────────────────────────────────────────┤
│ Compliance Health Snapshot              │ ← Visual grid, expandable drill-down
├─────────────────────────────────────────┤
│ Historical Trends (collapsible)         │ ← Charts, score evolution
└─────────────────────────────────────────┘
```

## Component 1: Action Items Inbox

**Purpose:** Unified prioritized list combining urgent deadlines AND assessment recommendations.

### Priority Levels

- **Critical** (red): Overdue items, <24h deadlines for breach notifications
- **High** (orange): Upcoming deadlines (SARs due in <7 days), high-impact recommendations
- **Medium** (yellow): Normal recommendations, treatment reviews due
- **Low** (blue): Nice-to-have improvements, documentation updates

### Data Sources

1. **Regulatory Deadlines**
   - Data breaches: 72-hour notification window (tracked from `DataBreach.detected_at`)
   - Subject Access Requests: 30-day response window (tracked from `SubjectAccessRequest.received_at`)
   - Treatment registry reviews: Annual review reminders (from `ProcessingActivity.last_reviewed_at`)

2. **Assessment-Driven Recommendations**
   - Generated when compliance assessment completes
   - Intelligent prioritization: Quick wins first, major projects below
   - Each action is a guided workflow button with estimated score impact

### UI Behavior

Each action item shows:
- Priority badge (color-coded)
- Description: "Subject Access Request #23 - Due in 3 days"
- Action button: "Respond to SAR" / "Add encryption" / "Generate document"
- Impact indicator: "This will improve your Data Security score by ~15%"
- Dismiss/snooze option for non-critical items

**Features:**
- Collapsible sections by priority with counts: "Critical (2)" "High (5)" "Medium (8)"
- "Mark as done" checkbox moves items to history
- Auto-refresh when deadlines approach (WebSocket or polling)
- Filter toggles: Show all / Active only / Dismissed
- Complete button executes the guided workflow (redirects to appropriate page with context)

### Data Model

```ruby
class ActionItem < ApplicationRecord
  belongs_to :account
  belongs_to :actionable, polymorphic: true # DataBreach, SubjectAccessRequest, ComplianceAssessment, ProcessingActivity

  enum source: { assessment: 0, regulatory_deadline: 1, system_recommendation: 2 }
  enum priority: { low: 0, medium: 1, high: 2, critical: 3 }
  enum status: { pending: 0, in_progress: 1, completed: 2, dismissed: 3 }
  enum action_type: {
    update_treatment: 0,
    generate_document: 1,
    complete_wizard: 2,
    respond_to_sar: 3,
    notify_breach: 4
  }

  # Fields:
  # - title (string)
  # - description (text)
  # - action_params (jsonb) - IDs/context needed for the action
  # - due_at (datetime)
  # - impact_score (integer) - estimated compliance score improvement
  # - snoozed_until (datetime)
end
```

## Component 2: Quick Actions Panel

Positioned below the Action Items Inbox, provides one-click access to common operations that aren't urgent/deadline-driven.

### Actions Grouped by Category

**1. Assessments**
- "Start New Assessment" → creates new Response, redirects to questionnaire
- Shows: Last assessment date, current score badge

**2. Documents**
- "Generate Privacy Policy" → launches privacy policy wizard
- "Generate Document" → shows document type picker
- Shows: Document status ("Privacy Policy: Generated 45 days ago, expires in 320 days")

**3. Treatment Registry**
- "Add Processing Activity" → launches treatment creation wizard
- "View All Treatments" → navigates to ProcessingActivities/Index
- Shows: Treatment count badge ("12 active treatments")

**4. Incident Management**
- "Report Data Breach" → launches breach logging wizard
- "Log Subject Access Request" → launches SAR intake form

## Component 3: Compliance Health Snapshot

Grid/card layout showing all compliance areas with actionable drill-down.

### Top Level (At-a-Glance)

Each compliance area card displays:
- Area name and icon (e.g., "Data Security" 🔒)
- Color-coded background (green/yellow/red based on risk level)
- Large percentage score: "78%"
- Status badge: "Compliant" / "Needs Attention" / "At Risk"

### Drill-Down (Click to Expand)

Shows:
- List of questions from this area answered poorly (<60% score)
- Each weak question displays:
  - Question text
  - User's answer
  - Recommended action
- "Fix this" button launches appropriate workflow
- Links to related treatments/documents that address this gap

### Mobile Optimization

- Cards stack vertically on narrow screens
- Touch-friendly expandable sections
- Minimum 44px touch targets

## Component 4: Historical Trends

Collapsible section at bottom of dashboard (initially closed to reduce visual noise).

### When Expanded

**1. Overall Score Evolution**
- Line chart showing compliance score over time
- X-axis: Assessment dates
- Y-axis: Percentage score (0-100%)
- Color zones: Green (>80%), Yellow (60-80%), Red (<60%)
- Data points clickable → navigates to that assessment's results

**2. Area Breakdown Trends**
- Small multiples chart: one mini line chart per compliance area
- Shows which areas are improving vs declining
- Hover shows exact scores and dates

**3. Incident Timeline** (if breaches/SARs exist)
- Visual timeline showing breach/SAR occurrences
- Correlated with compliance scores: "Score dropped after breach in Customer Data treatment"

## New Data Models

### Data Breaches

```ruby
class DataBreach < ApplicationRecord
  belongs_to :account
  belongs_to :processing_activity, optional: true # Phase 1: optional, Phase 2+: required
  has_many :action_items, as: :actionable

  enum severity: { minor: 0, moderate: 1, major: 2, critical: 3 }
  enum status: { detected: 0, under_investigation: 1, notified: 2, resolved: 3 }

  # Fields:
  # - detected_at (datetime)
  # - description (text)
  # - affected_records_count (integer)
  # - notification_required (boolean)
  # - notified_at (datetime)
  # - resolved_at (datetime)
end
```

### Subject Access Requests

```ruby
class SubjectAccessRequest < ApplicationRecord
  belongs_to :account
  belongs_to :processing_activity, optional: true # Phase 1: optional, Phase 2+: required
  has_many :action_items, as: :actionable

  enum status: { received: 0, in_progress: 1, completed: 2, overdue: 3 }

  # Fields:
  # - received_at (datetime)
  # - requester_email (string)
  # - requester_name (string)
  # - due_at (datetime) - calculated as received_at + 30 days
  # - completed_at (datetime)
  # - response_sent_at (datetime)
end
```

## Backend Architecture

### Controllers

```
app/controllers/dashboard_controller.rb (enhanced)
app/controllers/action_items_controller.rb (create, update, dismiss)
app/controllers/data_breaches_controller.rb (new, create, update)
app/controllers/subject_access_requests_controller.rb (new, create, update)
```

### Services

```
app/services/action_item_generator.rb
  # Creates action items from assessment results
  # Maps poor scores to specific recommended actions

app/services/deadline_monitor.rb
  # Background job (daily) to check all deadlines
  # Escalates priority as due dates approach
  # Creates urgent action items

app/services/breach_notification_wizard.rb
  # Guides breach response workflow
  # Assesses severity, determines if 72h notification required
  # Generates notification template for CCIN

app/services/sar_response_wizard.rb
  # Guides SAR response workflow
  # Checklist for gathering data
  # Generates response template
  # Tracks 30-day deadline
```

### Integration Points

1. **Assessment completion** → triggers `ActionItemGenerator` → creates recommended actions
2. **Data breach logged** → creates `ActionItem` with 72h deadline → appears in inbox as critical
3. **SAR received** → creates `ActionItem` with 30-day deadline → appears in inbox
4. **Treatment registry** → annual review reminder → creates medium-priority action item
5. **Background job** (daily): `DeadlineMonitor` checks all deadlines, escalates priority as due dates approach

## Frontend Structure (Svelte 5)

```
app/frontend/pages/Dashboard/Show.svelte (enhanced)
├── components/dashboard/ActionItemsInbox.svelte
│   ├── ActionItem.svelte (individual item with priority badge + action button)
│   └── InboxFilters.svelte (show all/active/dismissed)
├── components/dashboard/QuickActionsPanel.svelte
├── components/dashboard/ComplianceHealthSnapshot.svelte
│   └── ComplianceAreaCard.svelte (expandable drill-down)
└── components/dashboard/HistoricalTrends.svelte
    ├── ScoreEvolutionChart.svelte
    └── AreaBreakdownChart.svelte
```

## Implementation Phases

### Phase 1: Foundation (Week 1-2)

**Scope:**
- Enhance existing dashboard with Action Items Inbox
- `ActionItem` model + controller + basic CRUD
- Assessment-driven recommendations only (no breaches/SARs yet)
- Quick Actions Panel
- Enhanced Compliance Health Snapshot with drill-down

**Deliverables:**
- Users see recommended actions from assessments in prioritized inbox
- Can dismiss/snooze action items
- Can drill down into compliance areas to see weak questions
- Quick access to common tasks

### Phase 2: Incident Management (Week 3-4)

**Scope:**
- `DataBreach` model + logging workflow
- `SubjectAccessRequest` model + logging workflow
- Basic deadline tracking → creates action items
- No guided wizards yet (just forms to log incidents)

**Deliverables:**
- Users can log data breaches and SARs
- Deadlines automatically create action items in inbox
- Critical priority for breaches approaching 72h deadline
- Basic incident list views

### Phase 3: Guided Workflows (Week 5-6)

**Scope:**
- Breach notification wizard with severity assessment
- SAR response wizard with data gathering checklist
- Document template generation for both
- Treatment linkage for incidents

**Deliverables:**
- Step-by-step wizards guide users through breach response
- SAR response checklist ensures complete data gathering
- Generated templates for notifications/responses
- Incidents linked to processing activities

### Phase 4: Intelligence & Trends (Week 7-8)

**Scope:**
- Historical trends charts
- Assessment scoring integration (breach/SAR history influences scores)
- Treatment linkage required for incidents (no longer optional)
- AI assistant integration for incident response

**Deliverables:**
- Users see compliance score evolution over time
- Breach/SAR patterns influence assessment scores
- "Customer Data treatment has 2 breaches → Security score lowered"
- AI chat can help draft breach notifications and SAR responses

## Competitive Differentiation

**Most GDPR tools:**
- Just track deadlines (passive monitoring)
- Separate incident management from compliance assessment
- Static recommendations without guided workflows

**Monaco RGPD dashboard:**
- Active command center with actionable inbox
- Full interconnection: incidents → treatments → assessments → score impact
- Guided workflows turn every recommendation into a clickable action
- Compliance intelligence: "Here's what's broken AND here's proof it's causing real problems"

## Success Metrics

- Users can identify top 3 compliance priorities in <5 seconds
- 80%+ of action items completed (not dismissed)
- Average time from breach detection to notification: <24 hours
- Average SAR response time: <25 days (well under 30-day limit)
- Compliance scores improve measurably after completing recommended actions

## Future Enhancements

Deferred for later consideration:
- Customizable dashboard layouts (drag-and-drop cards)
- Email/SMS alerts for critical deadlines
- Automated breach severity assessment using AI
- Integration with external incident response platforms
- Multi-language support for SAR responses
- Bulk action item operations (dismiss all low priority, etc.)
