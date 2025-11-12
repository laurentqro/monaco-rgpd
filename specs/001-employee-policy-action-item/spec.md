# Feature Specification: Employee Privacy Policy Distribution Reminder

**Feature Branch**: `001-employee-policy-action-item`
**Created**: 2025-11-12
**Status**: Draft
**Input**: User description: "When a user answers in the questionnaire that they have employees, an employee privacy policy gets generated. But that's not the end of it. The user must send that document to all employees, to inform them about the data that is collected (what data, the legal basis, etc.). In practice, it means that answer should trigger the creation of an action item titled 'Envoyer politique de confidentialite a vos salaries'."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automatic Reminder to Distribute Employee Privacy Policy (Priority: P1)

When a business owner completes the questionnaire and indicates they have employees, the system generates an employee privacy policy document. However, generating the document is not enough - Monaco Law 1.565 requires that employees be informed about how their personal data is collected and processed. The business owner needs a clear reminder to distribute this policy to all employees.

**Why this priority**: This is a legal compliance requirement. Failure to inform employees about data processing could result in GDPR/Monaco Law 1.565 violations. The reminder ensures business owners don't overlook this critical step after receiving their privacy policy document.

**Independent Test**: Can be fully tested by completing a questionnaire where the user indicates they have employees, and verifying that an action item reminder appears in their dashboard immediately after document generation.

**Acceptance Scenarios**:

1. **Given** a user is completing the compliance questionnaire, **When** they answer "Oui" to the question "Avez-vous du personnel ?", **Then** the system creates an action item titled "Envoyer politique de confidentialité à vos salariés" linked to their account

2. **Given** an action item for distributing employee privacy policy exists, **When** the user views their action items dashboard, **Then** they see the reminder with clear explanation of why they need to send the document to employees

3. **Given** a user has completed distributing the privacy policy to employees, **When** they mark the action item as completed, **Then** the action item status updates and it moves out of the pending list

4. **Given** a user answers "Non" to "Avez-vous du personnel ?", **When** the questionnaire is completed, **Then** no employee privacy policy action item is created

5. **Given** a user changes their answer from "Non" to "Oui" for the employee question, **When** the response is updated, **Then** the action item is created if it doesn't already exist

### Edge Cases

- What happens when a user updates their questionnaire answer from "Oui" to "Non" after the action item was created? (Action item should remain visible but could be marked as "no longer applicable")
- How does the system handle incomplete questionnaires where the employee question hasn't been answered yet? (No action item created until answer is provided)
- What happens if the privacy policy document generation fails? (Action item creation could be deferred until document successfully generates, or created with note about document pending)
- What if a user already has an employee privacy policy action item and re-takes the questionnaire? (Avoid duplicate action items)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST automatically create an action item when a questionnaire answer indicates the business has employees
- **FR-002**: The action item MUST have the title "Envoyer politique de confidentialité à vos salariés"
- **FR-003**: The action item MUST include a description explaining the legal obligation to inform employees about data collection and processing
- **FR-004**: The action item MUST be linked to the account and the questionnaire response that triggered it
- **FR-005**: The action item MUST be linked to the generated employee privacy policy document (if available)
- **FR-006**: Users MUST be able to view the action item in their action items list or dashboard
- **FR-007**: Users MUST be able to mark the action item as completed once they have distributed the policy
- **FR-008**: Users MUST be able to dismiss or snooze the action item if they need to postpone the task
- **FR-009**: System MUST NOT create duplicate action items if the user re-submits the same questionnaire response
- **FR-010**: System MUST only create the action item when the specific answer "Oui" is given to the employee question

### Key Entities

- **ActionItem**: Represents a task or reminder for the user. Contains title, description, priority, status (pending/completed/dismissed), due date, and links to related entities (account, questionnaire response, document)
- **QuestionnaireResponse**: Links the action item to the specific questionnaire submission that triggered its creation
- **EmployeePrivacyPolicyDocument**: The generated document that users need to distribute; action item should reference this document so users can easily access it
- **Account**: The business account that owns the action item and must complete the distribution task

### Dependencies and Assumptions

**Dependencies:**
- Existing action items system (model, dashboard/list view, completion/dismissal functionality)
- Existing questionnaire system with the employee question "Avez-vous du personnel ?"
- Existing employee privacy policy document generation process

**Assumptions:**
- Action items can be viewed immediately after creation without requiring page refresh
- Users understand their legal obligation to inform employees about data collection (may need brief educational content in action item description)
- Business owners have a method to distribute documents to employees (email, paper, etc.) - system doesn't manage the distribution method
- Default action item priority for legal compliance reminders is "high"
- Action items remain accessible even after completion for audit trail purposes

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of users who indicate they have employees receive the distribution reminder action item immediately after completing the questionnaire
- **SC-002**: Users can access their privacy policy document directly from the action item within 2 clicks
- **SC-003**: The action item description clearly explains the legal obligation in under 100 words
- **SC-004**: Users can complete or dismiss the action item in under 30 seconds
- **SC-005**: Zero duplicate action items are created for the same questionnaire response
- **SC-006**: Action item appears in the user's dashboard within 1 second of questionnaire completion
