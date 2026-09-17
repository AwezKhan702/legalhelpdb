-- DRAFT, DRAFT_VERSION, CLIENT_COMMENT, APPROVAL (FSD §14, §15, §42)

CREATE TABLE drafts.drafts (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    service_id      uuid REFERENCES catalog.services (id),
    title           text NOT NULL,
    language_code   text NOT NULL DEFAULT 'en' REFERENCES catalog.languages (code),
    status          drafts.draft_status NOT NULL DEFAULT 'drafting',
    current_version integer NOT NULL DEFAULT 1,
    created_by      uuid NOT NULL REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE drafts.draft_versions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    draft_id        uuid NOT NULL REFERENCES drafts.drafts (id) ON DELETE CASCADE,
    version_no      integer NOT NULL,
    body            text,
    storage_key     text,
    created_by      uuid NOT NULL REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (draft_id, version_no)
);

CREATE TABLE drafts.client_comments (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    draft_id        uuid NOT NULL REFERENCES drafts.drafts (id) ON DELETE CASCADE,
    version_id      uuid REFERENCES drafts.draft_versions (id) ON DELETE SET NULL,
    author_id       uuid NOT NULL REFERENCES identity.users (id),
    body            text NOT NULL,
    resolved_at     timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE drafts.approvals (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    draft_id        uuid NOT NULL REFERENCES drafts.drafts (id) ON DELETE CASCADE,
    version_id      uuid REFERENCES drafts.draft_versions (id),
    approver_id     uuid NOT NULL REFERENCES identity.users (id),
    approved        boolean NOT NULL,
    remarks         text,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER drafts_set_updated_at
    BEFORE UPDATE ON drafts.drafts
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
