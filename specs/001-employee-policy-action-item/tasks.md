---

description: "Task list for employee privacy policy distribution reminder feature"
---

# Tasks: Employee Privacy Policy Distribution Reminder

**Input**: Design documents from `/specs/001-employee-policy-action-item/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/, quickstart.md

**Tests**: Test-Driven Development (TDD) is MANDATORY per project constitution. Tests are written FIRST, must FAIL, then implementation follows Red-Green-Refactor cycle.

**Organization**: Tasks are organized by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1 in this case)
- Include exact file paths in descriptions

## Path Conventions

Rails 8 web application structure:
- **Backend**: `app/` (models, services, controllers)
- **Tests**: `test/` (models, services, integration)
- **Fixtures**: `test/fixtures/`

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Verify environment and add test fixtures for the feature

- [ ] T001 Verify Rails 8.0 and Ruby 3.3 environment is ready
- [ ] T002 [P] Add employee question fixture to test/fixtures/questions.yml
- [ ] T003 [P] Add "Oui"/"Non" answer choice fixtures to test/fixtures/answer_choices.yml

---

## Phase 2: Foundational (No Blocking Prerequisites)

**Purpose**: No foundational tasks required - feature leverages existing infrastructure

> ✅ **All prerequisites already exist**: ActionItem model, Answer model, questionnaire system, action items dashboard

**Checkpoint**: Ready to begin User Story 1 implementation

---

## Phase 3: User Story 1 - Automatic Reminder to Distribute Employee Privacy Policy (Priority: P1) 🎯 MVP

**Goal**: Automatically create action item reminder when users indicate they have employees in compliance questionnaire, ensuring Monaco Law 1.565 compliance for employee data processing transparency.

**Independent Test**: Complete questionnaire indicating employees → verify action item appears in dashboard with correct title, priority, and description

### Tests for User Story 1 (TDD - Write FIRST, Watch FAIL)

> **⚠️ CONSTITUTION REQUIREMENT**: Tests MUST be written before implementation and MUST fail initially

- [ ] T004 [P] [US1] Write service object test "creates action item when answer is Oui to employee question" in test/services/employee_policy_action_creator_test.rb
- [ ] T005 [P] [US1] Write service object test "does not create duplicate action items" in test/services/employee_policy_action_creator_test.rb
- [ ] T006 [P] [US1] Write service object test "does not create action item for non-employee question" in test/services/employee_policy_action_creator_test.rb
- [ ] T007 [P] [US1] Write Answer model callback test "creates action item after commit when answer is Oui" in test/models/answer_test.rb
- [ ] T008 [P] [US1] Write Answer model callback test "does not create action item when answer is Non" in test/models/answer_test.rb
- [ ] T009 [US1] Run tests to verify they FAIL (RED phase) - bin/rails test

### Implementation for User Story 1 (Make Tests GREEN)

- [ ] T010 [US1] Create EmployeePolicyActionCreator service object in app/services/employee_policy_action_creator.rb (~80 LOC: constants, initialize, call, private methods for should_create, is_yes_answer, action_item_already_exists, create_action_item!)
- [ ] T011 [US1] Run service tests to verify they PASS (GREEN phase) - bin/rails test test/services/employee_policy_action_creator_test.rb
- [ ] T012 [US1] Add after_commit callback to Answer model in app/models/answer.rb (call service with error handling)
- [ ] T013 [US1] Run Answer model tests to verify they PASS (GREEN phase) - bin/rails test test/models/answer_test.rb
- [ ] T014 [US1] Write integration test for end-to-end flow in test/integration/employee_policy_action_flow_test.rb (complete questionnaire → verify action item created)
- [ ] T015 [US1] Run integration test to verify PASS - bin/rails test test/integration/employee_policy_action_flow_test.rb
- [ ] T016 [US1] Run Rubocop style check on new service - bin/rubocop app/services/employee_policy_action_creator.rb
- [ ] T017 [US1] Fix any Rubocop violations in service object

**Checkpoint**: At this point, User Story 1 should be fully functional with passing tests and compliant code style

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and documentation

- [ ] T018 [P] Run full test suite to ensure no regressions - bin/rails test
- [ ] T019 [P] Manual UI verification: Start bin/dev, complete questionnaire with employees, verify action item appears in /action_items
- [ ] T020 Verify performance requirement (<100ms action item creation) using Rails console benchmark script from quickstart.md
- [ ] T021 Check logs for any N+1 queries or errors during manual testing
- [ ] T022 Update CHANGELOG or commit message with feature description

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Not applicable - no blocking tasks
- **User Story 1 (Phase 3)**: Depends on Setup fixtures - can proceed after Phase 1
- **Polish (Phase 4)**: Depends on User Story 1 completion

### User Story Dependencies

- **User Story 1 (P1)**: No dependencies on other stories (only story in this feature)
  - Tests MUST be written before implementation (T004-T009 before T010-T017)
  - Service object MUST pass tests before callback is added
  - Integration test validates end-to-end flow after all unit tests pass

### Within User Story 1

**TDD Workflow (MANDATORY)**:
1. **RED**: Write tests first (T004-T009) → Run tests → Verify they FAIL (T009)
2. **GREEN**: Implement service (T010-T011) → Implement callback (T012-T013) → Integration test (T014-T015)
3. **REFACTOR**: Style check and fixes (T016-T017)

**Sequential Dependencies**:
- T009 (verify tests fail) MUST run after T004-T008 (tests written)
- T010 (service implementation) MUST run after T009 (RED phase confirmed)
- T011 (verify service tests pass) MUST run after T010
- T012 (callback implementation) MUST run after T011 (service working)
- T013 (verify callback tests pass) MUST run after T012
- T014-T015 (integration) MUST run after T013 (unit tests passing)
- T016-T017 (style) MUST run after implementation complete

### Parallel Opportunities

**Phase 1 (Setup)**: T002 and T003 (fixtures) can run in parallel
**Phase 3 Tests**: T004-T008 (writing tests) can ALL run in parallel - they're independent test files
**Phase 4 Polish**: T018, T019, T020 can run in parallel

---

## Parallel Example: Writing Tests for User Story 1

```bash
# Launch all test writing tasks together (Phase 3):
# These can be done in parallel because they modify different test files
Task T004: Write service test "creates action item when answer is Oui"
Task T005: Write service test "does not create duplicate action items"
Task T006: Write service test "does not create action item for non-employee question"
Task T007: Write Answer callback test "creates action item after commit when answer is Oui"
Task T008: Write Answer callback test "does not create action item when answer is Non"

# After tests written, run them to verify RED phase:
Task T009: bin/rails test (should FAIL - RED phase)
```

---

## Implementation Strategy

### MVP First (Single User Story)

1. Complete Phase 1: Setup (fixtures)
2. Skip Phase 2: Foundational (no tasks)
3. Complete Phase 3: User Story 1 (TDD workflow)
   - **RED**: Write tests → Verify failure
   - **GREEN**: Implement service → Implement callback → Verify success
   - **REFACTOR**: Style check → Fix violations
4. **STOP and VALIDATE**: Integration test + Manual UI verification
5. Deploy/demo when ready

### TDD Workflow Enforcement

**Constitution Requirement**: Test-First Development is NON-NEGOTIABLE

1. **Always write tests FIRST** (T004-T009)
2. **Verify tests FAIL** (T009) - confirms tests are valid
3. **Implement minimal code** to make tests pass (T010-T015)
4. **Refactor** while keeping tests green (T016-T017)
5. **Never skip** the RED phase - failing tests prove they work

### Quality Gates

Before marking feature complete:
- ✅ All tests pass (T018)
- ✅ Manual UI verified (T019)
- ✅ Performance validated (T020)
- ✅ No N+1 queries (T021)
- ✅ Rubocop compliant (T016-T017)
- ✅ Pre-push hooks pass

---

## Notes

- [P] tasks = different files, no dependencies - can run in parallel
- [US1] label = belongs to User Story 1 (automatic reminder feature)
- TDD is mandatory: Write tests → Watch fail → Implement → Watch pass → Refactor
- Total LOC: ~90 implementation + ~180 tests = ~270 total
- No database migrations required (uses existing action_items table)
- No frontend changes required (existing UI displays action items automatically)
- Commit after each logical group of tasks
- Verify tests fail before implementing (RED phase critical for TDD)

---

## Task Completion Checklist

Use this checklist to track overall feature progress:

### Setup Complete
- [ ] Fixtures added for employee question and answer choices

### Tests Written (RED Phase)
- [ ] Service object tests written (3 tests)
- [ ] Answer model callback tests written (2 tests)
- [ ] Tests verified to FAIL

### Implementation Complete (GREEN Phase)
- [ ] Service object implemented and tested
- [ ] Answer callback implemented and tested
- [ ] Integration test passing
- [ ] Style checks passed

### Feature Ready
- [ ] All tests passing (unit + integration)
- [ ] Manual UI verification complete
- [ ] Performance validated (<100ms)
- [ ] No regressions in full test suite
- [ ] Ready for PR/deployment

---

## Reference Documents

- **Business requirements**: [spec.md](./spec.md)
- **Implementation plan**: [plan.md](./plan.md)
- **Technical decisions**: [research.md](./research.md)
- **Entity design**: [data-model.md](./data-model.md)
- **API contracts**: [contracts/action_item.md](./contracts/action_item.md)
- **Quick start guide**: [quickstart.md](./quickstart.md)
