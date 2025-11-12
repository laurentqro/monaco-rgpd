# ActionItem Contract: Employee Privacy Policy Distribution

**Date**: 2025-11-12
**Feature**: 001-employee-policy-action-item

## Overview

This document describes the ActionItem data structure for employee privacy policy distribution reminders. No new API endpoints are created - this feature uses existing ActionItems infrastructure.

## Existing Endpoint

**Controller**: `ActionItemsController`
**Route**: `GET /action_items` (via Inertia.js)
**Authentication**: Required (current_user session)
**Authorization**: User must belong to account

## ActionItem JSON Structure

### Employee Policy Action Item Response

```json
{
  "id": 123,
  "account_id": 456,
  "title": "Envoyer politique de confidentialité à vos salariés",
  "description": "Selon la Loi n° 1.565, vous devez informer vos salariés des données personnelles collectées, des finalités du traitement, et de la base légale. Veuillez distribuer la politique de confidentialité des salariés à l'ensemble de votre personnel.",
  "status": "pending",
  "priority": "high",
  "source": "assessment",
  "action_type": "generate_document",
  "actionable_type": "Response",
  "actionable_id": 789,
  "due_at": null,
  "snoozed_until": null,
  "impact_score": null,
  "action_params": {},
  "created_at": "2025-11-12T10:30:00Z",
  "updated_at": "2025-11-12T10:30:00Z"
}
```

### Field Descriptions

| Field | Type | Description | Constraints |
|-------|------|-------------|-------------|
| `id` | integer | Unique identifier | Primary key |
| `account_id` | integer | Account this action belongs to | Foreign key, not null |
| `title` | string | Action item title (French) | Not null, max 255 chars |
| `description` | text | Detailed explanation | Nullable |
| `status` | enum | Current status | One of: "pending", "in_progress", "completed", "dismissed" |
| `priority` | enum | Urgency level | One of: "low", "medium", "high", "critical" |
| `source` | enum | Origin of action | One of: "assessment", "regulatory_deadline", "system_recommendation" |
| `action_type` | enum | Type of action | One of: "update_treatment", "generate_document", "complete_wizard", "respond_to_sar", "notify_breach" |
| `actionable_type` | string | Polymorphic type | "Response" for this feature |
| `actionable_id` | integer | Polymorphic ID | Foreign key to responses table |
| `due_at` | datetime | Optional deadline | Nullable |
| `snoozed_until` | datetime | Snooze until time | Nullable |
| `impact_score` | integer | Optional impact score | Nullable |
| `action_params` | jsonb | Extra parameters | Default: {} |
| `created_at` | datetime | Creation timestamp | Not null |
| `updated_at` | datetime | Last update timestamp | Not null |

### Specific Values for Employee Policy Feature

| Field | Value | Rationale |
|-------|-------|-----------|
| `title` | "Envoyer politique de confidentialité à vos salariés" | Spec FR-002 requirement |
| `description` | Monaco Law explanation (see example above) | User guidance |
| `status` | "pending" | Initial state |
| `priority` | "high" | Legal compliance requirement |
| `source` | "assessment" | Triggered by questionnaire |
| `action_type` | "generate_document" | Closest semantic fit |
| `actionable_type` | "Response" | Links to questionnaire response |

## Inertia.js Props

### ActionItems Index Page

**Route**: `action_items#index`
**Component**: `ActionItems/Index.svelte`

**Props Structure**:
```typescript
interface Props {
  actionItems: ActionItem[];
  filters: {
    status?: 'pending' | 'in_progress' | 'completed' | 'dismissed';
    priority?: 'low' | 'medium' | 'high' | 'critical';
  };
  pagination: {
    current_page: number;
    total_pages: number;
    total_count: number;
  };
}

interface ActionItem {
  id: number;
  title: string;
  description: string;
  status: string;
  priority: string;
  source: string;
  action_type: string;
  due_at: string | null;
  created_at: string;
  updated_at: string;
  // Actionable association (if included)
  actionable?: {
    type: string;
    id: number;
    url?: string;  // Link to related resource
  };
}
```

## User Actions

### Mark Action Item Complete

**Route**: `PATCH /action_items/:id`
**Controller**: `ActionItemsController#update`
**Parameters**:
```json
{
  "action_item": {
    "status": "completed"
  }
}
```

**Response**: Updated ActionItem JSON (same structure as above)

### Dismiss Action Item

**Route**: `PATCH /action_items/:id`
**Controller**: `ActionItemsController#update`
**Parameters**:
```json
{
  "action_item": {
    "status": "dismissed"
  }
}
```

**Response**: Updated ActionItem JSON

### Snooze Action Item

**Route**: `PATCH /action_items/:id`
**Controller**: `ActionItemsController#update`
**Parameters**:
```json
{
  "action_item": {
    "snoozed_until": "2025-11-15T09:00:00Z"
  }
}
```

**Response**: Updated ActionItem JSON

## Frontend Display

### ActionItem Card (Existing Component)

**Component**: `ActionItemCard.svelte`
**Props**:
```typescript
interface ActionItemCardProps {
  id: number;
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'critical';
  status: 'pending' | 'in_progress' | 'completed' | 'dismissed';
  created_at: string;
  onComplete: (id: number) => void;
  onDismiss: (id: number) => void;
  onSnooze: (id: number, until: Date) => void;
}
```

**Visual Behavior**:
- High priority items shown with red/orange indicator
- "Envoyer politique..." title displayed prominently
- Description shows Monaco Law explanation
- Action buttons: "Marquer comme terminé", "Reporter", "Ignorer"

## Related Resource Links

### Link to Privacy Policy Document

If document exists, ActionItem can include link in `action_params`:
```json
{
  "action_params": {
    "document_id": 999,
    "document_url": "/documents/999/download"
  }
}
```

**Implementation**: Service can populate `action_params` with document reference if found via `response.documents.find_by(document_type: :employee_privacy_policy)`

## Validation Rules

### Status Transitions (Enforced by Controller)
- `pending` → `in_progress`, `completed`, `dismissed`
- `in_progress` → `completed`, `dismissed`
- `completed` / `dismissed` → (final states, no further transitions)

### Required Fields for Creation
- `account_id` (not null)
- `title` (not null)
- `source` (not null, valid enum)
- `actionable_type` and `actionable_id` (polymorphic association)

## Example Request/Response Flow

### 1. User Completes Questionnaire with Employees

**Request**: N/A (internal system event)
**Trigger**: `Answer.after_commit` callback
**Action**: Service creates ActionItem

### 2. User Views Action Items Dashboard

**Request**:
```
GET /action_items
Accept: application/json
X-Inertia: true
```

**Response** (Inertia.js props):
```json
{
  "component": "ActionItems/Index",
  "props": {
    "actionItems": [
      {
        "id": 123,
        "title": "Envoyer politique de confidentialité à vos salariés",
        "description": "Selon la Loi n° 1.565...",
        "status": "pending",
        "priority": "high",
        "source": "assessment",
        "action_type": "generate_document",
        "created_at": "2025-11-12T10:30:00Z"
      }
    ],
    "filters": { "status": "pending" },
    "pagination": { "current_page": 1, "total_pages": 1, "total_count": 1 }
  }
}
```

### 3. User Marks Action Complete

**Request**:
```
PATCH /action_items/123
Content-Type: application/json
X-Inertia: true

{
  "action_item": {
    "status": "completed"
  }
}
```

**Response** (Inertia.js props with updated item):
```json
{
  "component": "ActionItems/Index",
  "props": {
    "actionItems": [
      {
        "id": 123,
        "status": "completed",
        "updated_at": "2025-11-12T14:00:00Z",
        ...
      }
    ]
  }
}
```

## Error Handling

### Duplicate Action Item Prevention

Not applicable at API level - handled by service layer deduplication logic. No error response needed.

### Invalid Status Transition

**Response**: `422 Unprocessable Entity`
```json
{
  "errors": {
    "status": ["cannot transition from completed to pending"]
  }
}
```

### Unauthorized Access

**Response**: `403 Forbidden`
```json
{
  "error": "You are not authorized to access this action item"
}
```

## Summary

**New Endpoints**: None (uses existing ActionItemsController)
**Modified Endpoints**: None
**Contract Changes**: None (ActionItem structure unchanged)
**Frontend Changes**: None (existing components handle new action items automatically)
**Integration Point**: Inertia.js props from `action_items#index`
