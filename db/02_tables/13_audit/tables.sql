-- AUDIT_LOG (FSD §33, §35, §42)

CREATE TABLE audit.audit_logs (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id        uuid REFERENCES identity.users (id),
    action          text NOT NULL,
    entity_schema   text,
    entity_table    text,
    entity_id       uuid,
    case_id         uuid,
    ip_address      inet,
    user_agent      text,
    metadata        jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at      timestamptz NOT NULL DEFAULT now()
);
