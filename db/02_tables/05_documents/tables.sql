-- DOCUMENT, DOCUMENT_CATEGORY, DOCUMENT_VERSION, DOCUMENT_ACCESS_LOG, DOCUMENT_TAG (FSD §36, §42, Category L)

CREATE TABLE documents.document_categories (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code        text NOT NULL UNIQUE,
    name        text NOT NULL
);

CREATE TABLE documents.documents (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id             uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    category_id         uuid REFERENCES documents.document_categories (id),
    uploaded_by         uuid NOT NULL REFERENCES identity.users (id),
    title               text NOT NULL,
    original_filename   text,
    mime_type           text,
    evidence_number     text,
    storage_key         text,
    retention_state     documents.retention_state NOT NULL DEFAULT 'active',
    legal_hold          boolean NOT NULL DEFAULT false,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),
    deleted_at          timestamptz
);

CREATE TABLE documents.document_versions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id     uuid NOT NULL REFERENCES documents.documents (id) ON DELETE CASCADE,
    version_no      integer NOT NULL,
    storage_key     text NOT NULL,
    checksum_sha256 text,
    byte_size       bigint,
    uploaded_by     uuid NOT NULL REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (document_id, version_no)
);

CREATE TABLE documents.document_tags (
    id      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name    citext NOT NULL UNIQUE
);

CREATE TABLE documents.document_tag_map (
    document_id uuid NOT NULL REFERENCES documents.documents (id) ON DELETE CASCADE,
    tag_id      uuid NOT NULL REFERENCES documents.document_tags (id) ON DELETE CASCADE,
    PRIMARY KEY (document_id, tag_id)
);

CREATE TABLE documents.document_access_logs (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id     uuid NOT NULL REFERENCES documents.documents (id) ON DELETE CASCADE,
    actor_id        uuid REFERENCES identity.users (id),
    action          text NOT NULL,
    ip_address      inet,
    user_agent      text,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER documents_set_updated_at
    BEFORE UPDATE ON documents.documents
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
