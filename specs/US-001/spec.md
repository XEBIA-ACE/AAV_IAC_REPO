# Feature Specification: US-001

## User Scenarios & Testing
- **US-001**: Implement notification logic for trainer allocation and deallocation events, ensuring emails and optional SMS are sent containing details such as workshop name, schedule, venue/link, and coordinator contacts.
- **US-001**: Integrate merge field population when a notification template is applied. Validate the correct filling of fields like trainer name, workshop details, and contact information.
- **US-001**: Develop and enforce a retry policy mechanism within the notification system to handle transient errors from the email/SMS providers, adhering to configured retry rules and logging all failures.
- **US-001**: Ensure audit logging captures essential data including trainer details, workshop IDs, event type (allocation/deallocation), timestamp, and outcome of notification attempts.

## Functional Requirements
- FR-US-001-AC1-001: For every trainer allocation event, the system SHALL create a notification job that sends an email to the allocated primary trainer and each co-trainer, and SHALL, where SMS notifications are configured as enabled, create a notification job that sends an SMS to the same recipients, containing workshop name, schedule, venue or online link, and coordinator contact details, as required by US-001-ac-1 and the story description. Any ambiguity about which specific allocation-related events beyond allocation and deallocation (e.g., reallocation) must trigger notifications SHALL be treated as an open question and not implicitly extended in this requirement.
- FR-US-001-AC1-002: For every trainer deallocation event, the system SHALL create a notification job that sends an email to the affected primary trainer and each co-trainer, and SHALL, where SMS notifications are configured as enabled, create a notification job that sends an SMS to the same recipients, containing workshop name, schedule, venue or online link, and coordinator contact details, as required by US-001-ac-1 and the story description.
- FR-US-001-AC1-003: Notification dispatch for trainer allocation and deallocation events SHALL be performed asynchronously (e.g., via background processing or queuing) so that the user-facing allocation/deallocation workflow is not blocked or delayed by email/SMS sending operations, as stated in the story description and consistent with US-001-ac-1.
- FR-US-001-AC2-001: When a notification template is applied for a trainer allocation or deallocation event, the system SHALL populate all defined merge fields in the template using current data for the trainer(s), workshop, and coordinator, including at minimum trainer name, workshop details (such as name, schedule, and venue or online link), and coordinator contact information, as required by US-001-ac-2.
- FR-US-001-AC2-002: The system SHALL validate that all required merge fields in the selected notification template are successfully populated before the notification is queued for sending; if one or more required merge fields cannot be populated, the system SHALL mark the notification as failed due to template population error and SHALL NOT send the incomplete message, as required by US-001-ac-2. Any specific handling or messaging to end users in this case is not defined here and remains an open question.
- FR-US-001-AC3-001: The notification system SHALL implement a retry policy for transient errors returned by the configured email provider, using retry rules that are externally configurable (e.g., number of attempts and delay between attempts), and SHALL attempt to resend failed email notifications according to those rules, as required by US-001-ac-3. The exact classification of what constitutes a transient error versus a permanent error is not defined in the acceptance criteria and is therefore treated as an open specification detail.
- FR-US-001-AC3-002: The notification system SHALL implement a retry policy for transient errors returned by the configured SMS provider, using retry rules that are externally configurable (e.g., number of attempts and delay between attempts), and SHALL attempt to resend failed SMS notifications according to those rules, as required by US-001-ac-3. The exact classification of what constitutes a transient error versus a permanent error is not defined in the acceptance criteria and is therefore treated as an open specification detail.
- FR-US-001-AC3-003: For each retry attempt (for both email and SMS), the system SHALL log the attempt, the error received (if any), and the final outcome (success or failure) in a manner that can be queried or reported on, satisfying the requirement in US-001-ac-3 to log all failures and providing traceability of retry behavior.
- FR-US-001-AC4-001: For every trainer allocation and deallocation event that triggers notifications, the system SHALL create an audit log entry capturing at least: trainer identifier(s) and relevant trainer details, workshop identifier(s), the event type (allocation or deallocation), a timestamp for when the notification processing was performed, and the outcome of the notification process (for example, sent successfully, failed permanently after retries, or not sent due to configuration), as required by US-001-ac-4.
- FR-US-001-AC4-002: Audit log entries created under FR-US-001-AC4-001 SHALL be immutable records intended for traceability and compliance analysis; however, the specific retention period and access controls for these audit logs are not defined in US-001-ac-4 and are therefore explicitly left as open questions not resolved by this specification.

## Success Criteria
- **US-001-ac-1**: Implement notification logic for trainer allocation and deallocation events, ensuring emails and optional SMS are sent containing details such as workshop name, schedule, venue/link, and coordinator contacts.
- **US-001-ac-2**: Integrate merge field population when a notification template is applied. Validate the correct filling of fields like trainer name, workshop details, and contact information.
- **US-001-ac-3**: Develop and enforce a retry policy mechanism within the notification system to handle transient errors from the email/SMS providers, adhering to configured retry rules and logging all failures.
- **US-001-ac-4**: Ensure audit logging captures essential data including trainer details, workshop IDs, event type (allocation/deallocation), timestamp, and outcome of notification attempts.

## Provenance
- **Policy version**: `ace-spec-format/v1`
- **Repository baseline commit**: `e8db5f39d73ed1e23729a5edb660f02bb34779d2`
- **Accepted impact revision**: _none (no accepted_impact_hash)_
- **API impact touchpoints**:
  - Trainer allocation and deallocation HTTP endpoints exposed via Trainer Allocation API Controller, including /api/workshops/{id}/allocate-trainer and any related allocation/deallocation routes, which will now enqueue asynchronous notification jobs instead of performing any synchronous notification work. (evidence: artifact-SVC-001-c3, specs/US-001/spec.md)
  - Internal message-bus event TrainerAllocationNotificationRequested published by TrainerAllocationAppService to trigger background notification processing for trainer allocation/deallocation events. (evidence: artifact-SVC-001-c3, spec_technical_design:SVC-001:design_step_4)
  - AuditLog data model entries enriched to capture trainerId(s), workshopId, allocation event type, timestamps, and notification dispatch status/outcome for trainer allocation/deallocation flows. (evidence: spec_technical_design:SVC-001:design_step_3, spec_technical_design:SVC-001:design_step_10)
- **Technical design evidence**:
  - artifact-SVC-001-c3
  - artifact-SVC-001-c4
  - service:SVC-001

## Known Gaps & Open Questions
- Ambiguity about which specific allocation-related events beyond allocation and deallocation (e.g., reallocation) must trigger notifications is treated as an open question and is not implicitly specified.
- The exact classification of what constitutes a transient error versus a permanent error for email/SMS providers is not defined and remains an open specification detail.
- Specific handling or messaging to end users when template merge fields cannot be populated is not defined and remains an open question.
- Retention period and access controls for audit logs are not defined and remain explicitly out of scope for this specification.