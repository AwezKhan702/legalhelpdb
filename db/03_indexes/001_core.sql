-- Core lookup and access-path indexes.

CREATE INDEX idx_users_mobile ON identity.users (mobile);
CREATE INDEX idx_users_email ON identity.users (email);
CREATE INDEX idx_sessions_user ON identity.sessions (user_id) WHERE revoked_at IS NULL;

CREATE INDEX idx_cases_client ON cases.cases (client_user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_cases_assignee ON cases.cases (assigned_to) WHERE deleted_at IS NULL;
CREATE INDEX idx_cases_status ON cases.cases (status_id);
CREATE INDEX idx_cases_priority ON cases.cases (priority);
CREATE INDEX idx_cases_number ON cases.cases (case_number);
CREATE INDEX idx_case_timeline_case ON cases.case_timeline (case_id, occurred_at DESC);
CREATE INDEX idx_case_events_case ON cases.case_events (case_id, occurred_at);

CREATE INDEX idx_documents_case ON documents.documents (case_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_document_access_document ON documents.document_access_logs (document_id, created_at DESC);

CREATE INDEX idx_consultations_client ON consultations.consultations (client_user_id);
CREATE INDEX idx_consultations_consultant ON consultations.consultations (consultant_id);
CREATE INDEX idx_consultations_scheduled ON consultations.consultations (scheduled_at);

CREATE INDEX idx_drafts_case ON drafts.drafts (case_id);

CREATE INDEX idx_invoices_client ON billing.invoices (client_user_id);
CREATE INDEX idx_payments_invoice ON billing.payments (invoice_id);
CREATE INDEX idx_payments_status ON billing.payments (status);

CREATE INDEX idx_messages_case ON comms.messages (case_id, created_at);
CREATE INDEX idx_notifications_user ON comms.notifications (user_id, created_at DESC);

CREATE INDEX idx_followups_due ON followups.follow_ups (due_at) WHERE completed_at IS NULL;
CREATE INDEX idx_followups_case ON followups.follow_ups (case_id);

CREATE INDEX idx_audit_actor ON audit.audit_logs (actor_id, created_at DESC);
CREATE INDEX idx_audit_entity ON audit.audit_logs (entity_table, entity_id);
CREATE INDEX idx_audit_case ON audit.audit_logs (case_id);

CREATE INDEX idx_cases_problem_fts ON cases.cases
    USING gin (to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(problem_summary, '')));
