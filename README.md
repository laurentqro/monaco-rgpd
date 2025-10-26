# Monaco RGPD

[![CI](https://github.com/laurentqro/monaco-rgpd/actions/workflows/ci.yml/badge.svg)](https://github.com/laurentqro/monaco-rgpd/actions/workflows/ci.yml)
[![CD](https://github.com/laurentqro/monaco-rgpd/actions/workflows/cd.yml/badge.svg)](https://github.com/laurentqro/monaco-rgpd/actions/workflows/cd.yml)

Plateforme SaaS de conformité RGPD pour Monaco - Conforme à la Loi n° 1.565

## Stack Technique

- **Backend**: Rails 8.0.3
- **Database**: PostgreSQL 18
- **Frontend**: Svelte 5 (with runes)
- **Router**: Inertia.js
- **Styling**: Tailwind CSS v4 (OKLCH color space)
- **UI Components**: shadcn-svelte (with bits-ui primitives)

## Démarrage

```bash
bin/setup
bin/dev
```

## Documentation

- [Plan d'implémentation MVP](docs/plans/2025-10-14-monaco-rgpd-mvp.md)
- [Guide des composants UI](docs/ui-components.md)
- [Audit d'accessibilité](docs/accessibility-audit.md)
- [Correctifs d'accessibilité](docs/accessibility-fixes.md)
- [Guide de déploiement](docs/DEPLOYMENT.md)
