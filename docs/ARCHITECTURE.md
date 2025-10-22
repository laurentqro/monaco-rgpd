# Monaco RGPD - Architecture

## Overview

Monaco RGPD is a Rails 8 + Inertia.js + Svelte 5 SaaS platform for GDPR compliance.

## Tech Stack

- **Backend:** Rails 8.0.3
- **Database:** PostgreSQL 18
- **Frontend:** Svelte 5 + Inertia.js
- **Styling:** Tailwind CSS
- **Jobs:** SolidQueue
- **PDF Generation:** Prawn
- **Templates:** Liquid

## Domain Model

### Core Entities

1. **Account** - Multi-tenant organization
2. **User** - User within an account
3. **Questionnaire** - Master compliance questionnaire
4. **Response** - User's questionnaire submission
5. **ComplianceAssessment** - Calculated compliance score
6. **Document** - Generated compliance documents
7. **ProcessingActivity** - Article 27 register entry

### Key Relationships

```
Account
  ├── Users
  ├── Responses
  │   ├── Answers
  │   ├── ComplianceAssessment
  │   └── Documents
  └── ProcessingActivities
      ├── ProcessingPurposes
      ├── DataCategoryDetails
      ├── AccessCategories
      └── RecipientCategories

Questionnaire
  └── Sections
      └── Questions
          └── AnswerChoices
```

## Background Jobs

- **CalculateComplianceScoreJob** - Calculates compliance score after response completion
- **GenerateDocumentsJob** - Generates PDF documents from templates

## Security

- Multi-tenant row-level isolation via `account_id`
- JSONB encryption for sensitive data
- TLS 1.3 for all connections
- CSRF protection
- Content Security Policy

## Deployment

- Kamal 2 for containerized deployment
- EU-based hosting (Hetzner/OVH)
- PostgreSQL with encrypted backups
- Redis for queue backend
