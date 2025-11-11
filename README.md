# Monaco RGPD

[![CI](https://github.com/laurentqro/monaco-rgpd/actions/workflows/ci.yml/badge.svg)](https://github.com/laurentqro/monaco-rgpd/actions/workflows/ci.yml)

Plateforme SaaS de conformité RGPD pour Monaco - Conforme à la Loi n° 1.565

Une solution complète pour aider les entreprises monégasques à :
- Évaluer leur niveau de conformité RGPD
- Générer automatiquement leur registre des traitements
- Produire les documents obligatoires (politique de confidentialité, etc.)
- Bénéficier d'un assistant IA pour répondre aux questions de conformité

## Stack Technique

- **Backend**: Rails 8 (omakase-rails)
- **Database**: PostgreSQL 18
- **Frontend**: Svelte 5 (with runes)
- **Router**: Inertia.js
- **Styling**: Tailwind CSS v4 (OKLCH color space)
- **UI Components**: shadcn-svelte (with bits-ui primitives)
- **PDF Generation**: Grover (Chromium-based)
- **Background Jobs**: Solid Queue
- **Deployment**: Kamal 2

## Démarrage

```bash
# Installation et configuration initiale
bin/setup

# Lancer le serveur de développement
bin/dev
```

## Développement

### Tests

```bash
# Lancer tous les tests
bin/rails test

# Tests système
bin/rails test:system

# Audits de sécurité
bin/bundler-audit
bin/brakeman
```

### Git Hooks

Le projet utilise [Lefthook](https://github.com/evilmartians/lefthook) pour automatiser les validations :

- **Pre-commit**: Rubocop avec auto-correction sur les fichiers Ruby modifiés
- **Pre-push**: Audits de sécurité + suite de tests complète
- **Post-merge**: Installation automatique des dépendances et migrations

### Linting

```bash
# Vérifier le style du code Ruby
bin/rubocop

# Auto-corriger les problèmes de style
bin/rubocop -A
```

## Déploiement

Le déploiement en production se fait manuellement via Kamal :

```bash
kamal deploy --roles=web
```

Voir le [guide de déploiement](docs/DEPLOYMENT.md) pour plus de détails.

## Documentation

### Planification & Architecture
- [Plan d'implémentation MVP](docs/plans/2025-10-14-monaco-rgpd-mvp.md)
- [Guide de déploiement](docs/DEPLOYMENT.md)

### Interface Utilisateur
- [Guide des composants UI](docs/ui-components.md)
- [Audit d'accessibilité](docs/accessibility-audit.md)
- [Correctifs d'accessibilité](docs/accessibility-fixes.md)

## Couverture des Tests

- **Line Coverage**: 81.92%
- **Branch Coverage**: 61.42%
- **324 tests**, 752 assertions
