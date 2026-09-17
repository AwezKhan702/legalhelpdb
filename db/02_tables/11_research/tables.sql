-- LEGAL_REFERENCE (FSD §42, Category J)

CREATE TABLE research.legal_references (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid REFERENCES cases.cases (id) ON DELETE SET NULL,
    title           text NOT NULL,
    citation        text,
    source          text,
    summary         text,
    storage_key     text,
    created_by      uuid REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now()
);
