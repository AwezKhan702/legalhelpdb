CREATE OR REPLACE VIEW cases.v_open_cases AS
SELECT
    c.id,
    c.case_number,
    c.title,
    c.priority,
    cs.code AS status_code,
    cs.name AS status_name,
    c.client_user_id,
    c.assigned_to,
    c.sla_due_at,
    c.created_at
FROM cases.cases c
JOIN cases.case_statuses cs ON cs.id = c.status_id
WHERE c.deleted_at IS NULL
  AND cs.is_terminal = false;

CREATE OR REPLACE VIEW followups.v_due_followups AS
SELECT
    f.id,
    f.case_id,
    c.case_number,
    f.followup_type,
    f.title,
    f.due_at,
    f.assigned_to
FROM followups.follow_ups f
JOIN cases.cases c ON c.id = f.case_id
WHERE f.completed_at IS NULL;

CREATE OR REPLACE VIEW billing.v_payment_summary AS
SELECT
    p.id,
    p.invoice_id,
    i.invoice_number,
    p.client_user_id,
    p.status,
    p.amount,
    p.currency,
    p.created_at
FROM billing.payments p
JOIN billing.invoices i ON i.id = p.invoice_id;
