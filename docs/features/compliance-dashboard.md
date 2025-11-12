# Compliance Dashboard

## Overview

The compliance dashboard is the central command center for monitoring and improving GDPR compliance. It provides a prioritized action items inbox, quick access to common tasks, and detailed visibility into compliance health across all areas.

## Features

### 1. Action Items Inbox

Automatically generated recommendations based on compliance assessment results:

- **Priority levels:** Critical, High, Medium, Low
- **Smart prioritization:** Items ordered by priority and impact score
- **One-click actions:** Mark as completed or dismiss
- **Impact visibility:** Shows estimated compliance score improvement

**How it works:**
- When a compliance assessment is completed, `ActionItemGenerator` analyzes area scores
- Creates action items for areas scoring below 80%
- Priority determined by score gap (< 60% = high, 60-79% = medium)

### 2. Quick Actions Panel

Fast access to common compliance tasks:

- Start new compliance assessment
- Access document generation
- View processing activities registry
- Shows contextual information (last assessment date, document status, treatment count)

### 3. Compliance Health Snapshot

Visual breakdown of compliance by area:

- **Color-coded cards:** Green (compliant), Yellow (attention required), Red (non-compliant)
- **Expandable details:** Click any card to see detailed information and recommendations
- **Risk level badges:** Instant visual feedback on compliance status
- **Responsive grid:** Adapts to screen size (1-3 columns)

## Technical Architecture

### Backend

**Models:**
- `ActionItem`: Stores recommended actions
- Associations: `account`, `actionable` (polymorphic)

**Services:**
- `ActionItemGenerator`: Creates recommendations from assessment results

**Controllers:**
- `DashboardController#show`: Passes action items and enhanced assessment data
- `ActionItemsController#update`: Handles marking items as completed/dismissed

### Frontend

**Components:**
- `ActionItemsInbox.svelte`: Groups and displays action items by priority
- `ActionItem.svelte`: Individual action item card with complete/dismiss buttons
- `QuickActionsPanel.svelte`: Grid of quick access buttons
- `ComplianceHealthSnapshot.svelte`: Grid of compliance area cards
- `ComplianceAreaCard.svelte`: Expandable area detail card

## Usage

### For Users

1. Complete a compliance assessment
2. Dashboard automatically shows recommended actions based on weak areas
3. Click "Terminé" to mark actions as completed
4. Click area cards in health snapshot to see details
5. Use quick actions for common tasks

### For Developers

**Adding new action types:**

1. Add enum value to `ActionItem.action_type`
2. Update `ActionItemGenerator#determine_action_type` logic
3. Implement corresponding frontend action handler

**Customizing priorities:**

Modify `ActionItemGenerator#determine_priority` thresholds

**Adding new quick actions:**

Update `QuickActionsPanel.svelte` grid with new action button

## Future Enhancements (Phase 2+)

- Regulatory deadline tracking (data breaches, SARs)
- Snooze functionality for action items
- Filter/search in action items inbox
- Historical trends charts
- AI-powered action recommendations
