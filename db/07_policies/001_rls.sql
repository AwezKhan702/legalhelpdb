-- Row Level Security starters. Enable in the API role; superuser bypasses RLS.
ALTER TABLE cases.cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE comms.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE billing.invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY cases_owner_or_staff ON cases.cases
    USING (
        client_user_id = current_setting('app.user_id', true)::uuid
        OR current_setting('app.is_staff', true) = 'true'
    );

CREATE POLICY documents_via_case ON documents.documents
    USING (
        EXISTS (
            SELECT 1
            FROM cases.cases c
            WHERE c.id = documents.case_id
              AND (
                    c.client_user_id = current_setting('app.user_id', true)::uuid
                    OR current_setting('app.is_staff', true) = 'true'
                  )
        )
    );

CREATE POLICY messages_via_case ON comms.messages
    USING (
        sender_id = current_setting('app.user_id', true)::uuid
        OR current_setting('app.is_staff', true) = 'true'
        OR EXISTS (
            SELECT 1
            FROM cases.cases c
            WHERE c.id = comms.messages.case_id
              AND c.client_user_id = current_setting('app.user_id', true)::uuid
        )
    );

CREATE POLICY invoices_owner_or_staff ON billing.invoices
    USING (
        client_user_id = current_setting('app.user_id', true)::uuid
        OR current_setting('app.is_staff', true) = 'true'
    );
