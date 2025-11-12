<!--
Sync Impact Report - Version 1.0.0
================================================================================
Version change: [Initial Template] → 1.0.0
Bump rationale: MINOR - Initial constitution ratification with 7 foundational principles

Modified principles:
- Initial creation of all 7 principles

Added sections:
- I. Test-First Development (NON-NEGOTIABLE)
- II. Full-Stack Integration Patterns
- III. Rails Omakase Architecture
- IV. Component-Driven Frontend
- V. Security & Compliance by Design
- VI. Quality Gates & Automation
- VII. Simplicity & Maintainability
- Development Workflow
- Quality Standards

Templates requiring updates:
✅ plan-template.md - Constitution Check section aligns with TDD and architecture principles
✅ spec-template.md - User stories and requirements align with test-first approach
✅ tasks-template.md - Task structure supports TDD workflow with test tasks before implementation

Follow-up TODOs:
- None - all placeholders filled
================================================================================
-->

# Monaco RGPD Constitution

## Core Principles

### I. Test-First Development (NON-NEGOTIABLE)

**TDD is mandatory for all feature development:**
- Tests MUST be written before implementation code
- Tests MUST fail initially to verify they test the right behavior
- Follow strict Red-Green-Refactor cycle: Write failing test → Make it pass → Refactor
- No implementation without corresponding tests (unit, integration, or system as appropriate)
- Pre-push hooks enforce test suite passing before code can be pushed

**Rationale:** Test-first development ensures requirements are clear before coding begins,
creates living documentation, prevents regressions, and catches bugs early when they're
cheapest to fix. This is non-negotiable because GDPR compliance requires high reliability
and audit trails.

### II. Full-Stack Integration Patterns

**Rails backend and Svelte frontend must integrate seamlessly:**
- Use Inertia.js as the integration layer between Rails and Svelte
- Backend provides JSON responses via Inertia, frontend renders with Svelte components
- Props flow from Rails controllers to Svelte pages via Inertia
- Server-side validation in Rails, client-side reactivity in Svelte
- Both layers must be tested: Rails system tests with Capybara, Svelte component tests

**Rationale:** Clear integration patterns prevent impedance mismatches between backend and
frontend, reduce debugging time, and ensure consistent data flow throughout the application.

### III. Rails Omakase Architecture

**Follow Rails conventions and omakase stack principles:**
- Convention over configuration: use Rails defaults unless strong justification exists
- Turbo for dynamic updates without JavaScript framework overhead (where Inertia doesn't apply)
- Use Rails built-in features: Action Mailer, Active Job with Solid Queue, Action Cable
- Database migrations for all schema changes with rollback strategies
- Strong parameters for controller input validation
- Service objects only when business logic exceeds controller/model responsibilities

**Rationale:** Rails omakase provides a cohesive, battle-tested stack that minimizes decision
fatigue and leverages community best practices. Deviating introduces maintenance burden.

### IV. Component-Driven Frontend

**Svelte 5 with runes for reactive, maintainable UI:**
- Use Svelte 5 runes ($state, $derived, $effect) for state management
- Component hierarchy: Pages → Layouts → Features → UI primitives
- UI primitives from shadcn-svelte (built on bits-ui) for accessibility
- Tailwind CSS v4 with OKLCH color space for consistent styling
- Components must be independently testable and documented

**Rationale:** Component-driven development enables reusability, testability, and parallel
development. Shadcn-svelte ensures accessibility compliance (critical for GDPR-adjacent
requirements), while Svelte 5 runes provide explicit reactivity without framework overhead.

### V. Security & Compliance by Design

**Security and GDPR compliance are first-class concerns:**
- Security audits before every push (bundler-audit via pre-push hook)
- Brakeman static analysis for Rails vulnerabilities
- Personal data handling must follow Monaco Law 1.565 requirements
- Audit trails for sensitive operations (user consent, data exports, deletions)
- Environment variables for secrets (never commit credentials)
- Content Security Policy headers configured

**Rationale:** As a GDPR compliance platform, Monaco RGPD must exemplify best practices.
Security vulnerabilities or compliance failures would destroy user trust and violate the
platform's core mission.

### VI. Quality Gates & Automation

**Automated checks enforce quality standards:**
- **Pre-commit**: Rubocop auto-correction on staged Ruby files
- **Pre-push**: Security audits + full test suite must pass
- **Post-merge**: Auto-install dependencies and run migrations if changed
- CI/CD pipeline mirrors local checks (GitHub Actions)
- Code coverage tracked (currently 81.92% line, 61.42% branch)
- Deployment only from passing CI builds

**Rationale:** Automation prevents human error, ensures consistent quality, and enables
confident rapid iteration. Quality gates catch issues before they reach production.

### VII. Simplicity & Maintainability

**Start simple, add complexity only when justified:**
- YAGNI: Don't build features until they're needed
- Prefer boring solutions over clever ones
- Refactor when code becomes hard to understand
- Documentation lives with code (inline comments, README, docs/)
- Don't comment code. Write code in a way that is self-documenting.
- Delete unused code immediately (no commented-out blocks)
- Measure complexity: if a feature requires >3 models or >5 files, revisit design

**Rationale:** Complexity is the enemy of reliability. Simple systems are easier to test,
debug, and evolve. For a small team building a compliance platform, simplicity is a
competitive advantage.

## Development Workflow

**Feature development follows this sequence:**
1. Write specification (user stories, acceptance criteria)
2. Design implementation plan (architecture, file structure)
3. Write failing tests for each story
4. Implement minimal code to pass tests
5. Refactor while keeping tests green
6. Update documentation
7. Security audit + full test suite pass
8. Code review
9. Merge to main → Deploy via Kamal

**Branching strategy:** Feature branches off master, merge back after review.

## Quality Standards

**All code must meet these standards before merge:**
- ✅ All tests pass (unit, integration, system)
- ✅ Security audits clean (bundler-audit, brakeman)
- ✅ Rubocop compliant (auto-corrected via pre-commit)
- ✅ Coverage maintained or improved
- ✅ Documentation updated if behavior changed
- ✅ Accessibility validated for UI changes (WCAG 2.1 AA minimum)

**Exceptions require explicit justification in commit message and review approval.**

## Governance

**This constitution supersedes ad-hoc practices and informal decisions.**

**Amendments:**
- MUST be documented with rationale
- MUST update dependent templates (spec, plan, tasks)
- MUST follow semantic versioning:
  - MAJOR: Breaking changes to principles or removal of guarantees
  - MINOR: New principles or expanded guidance
  - PATCH: Clarifications, wording fixes, typos

**Compliance verification:**
- All PRs must reference constitution compliance in review
- Template files (plan, spec, tasks) must align with principles
- Complexity violations require justification in implementation plan

**Version**: 1.0.0 | **Ratified**: 2025-11-12 | **Last Amended**: 2025-11-12
