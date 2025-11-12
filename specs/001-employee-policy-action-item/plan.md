# Implementation Plan: Employee Privacy Policy Distribution Reminder

**Branch**: `001-employee-policy-action-item` | **Date**: 2025-11-12 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-employee-policy-action-item/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Automatically create action item reminder when users indicate they have employees in the compliance questionnaire. The action item prompts business owners to distribute the generated employee privacy policy to their staff, ensuring compliance with Monaco Law 1.565 legal obligations for employee data processing transparency.

**Technical approach**: Extend Answer model's after_save callback to detect "Oui" answer to employee question, then create ActionItem linked to Response and generated Document.

## Technical Context

**Language/Version**: Ruby 3.3 (Rails 8.0)
**Primary Dependencies**: Rails 8, Inertia.js 3.x, PostgreSQL 18
**Storage**: PostgreSQL 18 (action_items, responses, answers, documents tables)
**Testing**: Rails test framework (`bin/rails test`, `bin/rails test:system` for UI)
**Target Platform**: Web application (Linux server via Kamal 2 deployment)
**Project Type**: Web application (Rails backend + Svelte 5 frontend with Inertia.js integration)
**Performance Goals**: Action item creation <100ms, appear in dashboard <1 second
**Constraints**: Must not create duplicate action items for same response, must handle concurrent questionnaire submissions
**Scale/Scope**: Small feature - 1 model callback extension, 1 service object, existing UI displays action items

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Test-First Development (NON-NEGOTIABLE)

**Status**: ✅ **PASS**
- Tests will be written before implementation (answer callback test, service object test, integration test)
- Red-Green-Refactor cycle will be followed
- System tests will verify action item appears in dashboard

### II. Full-Stack Integration Patterns

**Status**: ✅ **PASS**
- Backend creates ActionItem via Rails model/service
- Frontend displays via existing Inertia.js action items page (no new integration needed)
- Props flow from ActionItemsController to Svelte ActionItemsList component

### III. Rails Omakase Architecture

**Status**: ✅ **PASS**
- Uses Rails conventions: ActiveRecord callback, service object pattern
- No deviation from Rails defaults
- Strong parameters for action item attributes
- Database migration for any schema changes (if needed)

### IV. Component-Driven Frontend

**Status**: ✅ **PASS** (No frontend changes required)
- Existing action items display components handle new item automatically
- No new UI components needed

### V. Security & Compliance by Design

**Status**: ✅ **PASS**
- Feature directly supports GDPR/Monaco Law 1.565 compliance
- No sensitive data in action item (references document by ID)
- Audit trail via action_items table timestamps

### VI. Quality Gates & Automation

**Status**: ✅ **PASS**
- Pre-commit Rubocop will check Ruby code style
- Pre-push tests will verify all tests pass
- No bypass of quality gates required

### VII. Simplicity & Maintainability

**Status**: ✅ **PASS**
- Simple feature: 1 callback method, 1 service object (~50 LOC total)
- No new dependencies
- Leverages existing action items infrastructure
- Well within complexity limits (<3 models, <5 files)

**Overall**: ✅ **ALL GATES PASS** - No complexity violations to justify

## Project Structure

### Documentation (this feature)

```text
specs/001-employee-policy-action-item/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
app/
├── models/
│   ├── answer.rb                          # MODIFY: Add after_save callback
│   └── action_item.rb                     # EXISTS: No changes needed
├── services/
│   └── employee_policy_action_creator.rb  # CREATE: New service object
└── controllers/
    └── action_items_controller.rb         # EXISTS: No changes needed

test/
├── models/
│   └── answer_test.rb                     # MODIFY: Add callback tests
├── services/
│   └── employee_policy_action_creator_test.rb  # CREATE: Service tests
└── integration/
    └── employee_policy_action_flow_test.rb     # CREATE: End-to-end test

db/
└── migrate/
    └── [timestamp]_add_fields_to_action_items.rb  # CREATE (if needed)
```

**Structure Decision**: Web application structure selected. This is a backend-only feature that extends existing Answer model behavior and leverages existing ActionItem infrastructure. Frontend automatically displays action items via existing Inertia.js pages, requiring no Svelte changes.

## Complexity Tracking

> **Not applicable** - No constitution violations detected. Feature passes all gates.

## Post-Design Constitution Re-Evaluation

*After completing Phase 0 (research) and Phase 1 (design), all gates re-evaluated:*

### Constitution Compliance Summary

**I. Test-First Development**: ✅ **CONFIRMED PASS**
- `quickstart.md` demonstrates complete TDD workflow
- Tests written first for service object, model callback, and integration
- Clear Red-Green-Refactor cycle documented

**II. Full-Stack Integration**: ✅ **CONFIRMED PASS**
- Service object creates ActionItem (backend)
- Existing Inertia.js infrastructure displays items (no new integration)
- Data model shows clean polymorphic associations

**III. Rails Omakase**: ✅ **CONFIRMED PASS**
- `after_commit` callback follows Rails 8 best practices
- Service object pattern standard in Rails community
- No schema changes needed (zero migrations)

**IV. Component-Driven Frontend**: ✅ **CONFIRMED PASS**
- Existing ActionItemCard component handles display
- No new Svelte components required
- Contract documents existing Inertia.js props structure

**V. Security & Compliance**: ✅ **CONFIRMED PASS**
- Feature enforces Monaco Law 1.565 compliance
- No sensitive data exposed in action items
- Audit trail via timestamps and status tracking

**VI. Quality Gates**: ✅ **CONFIRMED PASS**
- Rubocop will verify Ruby style
- Pre-push hook will run test suite
- Integration test ensures end-to-end flow

**VII. Simplicity**: ✅ **CONFIRMED PASS**
- Total implementation: 1 service object (~80 LOC), 1 callback method (~10 LOC)
- No new dependencies or external services
- Reuses existing infrastructure (ActionItem, Inertia.js, dashboard)
- File count: 2 new files (service + test), 2 modified (answer.rb + test)

**Final Verdict**: ✅ **ALL CONSTITUTION GATES PASS** - Ready for task generation (`/speckit.tasks`)

## Design Artifacts Generated

- ✅ `research.md` - 7 technical decisions documented with rationale
- ✅ `data-model.md` - Entity relationships and query patterns
- ✅ `contracts/action_item.md` - API contract (Inertia.js structure)
- ✅ `quickstart.md` - 5-minute TDD implementation guide
- ✅ Agent context updated (`CLAUDE.md`)

**Next Phase**: Run `/speckit.tasks` to generate implementation task breakdown.
