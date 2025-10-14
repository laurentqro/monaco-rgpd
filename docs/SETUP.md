# Monaco RGPD - Setup Guide

## Prerequisites

- Ruby 3.3+
- PostgreSQL 18
- Node.js 20+
- Redis (for SolidQueue)

## Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd monaco-rgpd

# Install dependencies
bundle install
npm install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start development server
bin/dev
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```
DATABASE_URL=postgresql://localhost/monaco_rgpd_development
REDIS_URL=redis://localhost:6379/0
```

## Seeding Data

The seeds include:
- Compliance areas (5 areas)
- Master questionnaire (5 sections, ~15 questions)
- Document templates (4 templates)

To re-seed:
```bash
rails db:seed
```

## Running Tests

```bash
# All tests
rails test

# With coverage
COVERAGE=true rails test
```

## Background Jobs

Development uses SolidQueue (PostgreSQL-backed queue):

```bash
# Jobs run automatically with bin/dev
# To run manually:
rails solid_queue:start
```

## Next Steps

1. Review and refine questionnaire questions with lawyer
2. Customize document templates
3. Configure production environment
4. Deploy to EU hosting
