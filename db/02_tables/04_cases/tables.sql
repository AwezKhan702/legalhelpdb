-- CASE and related entities (FSD §6, §8, §9, §16, §40, §42, §47, §48)

CREATE TABLE cases.case_statuses (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code        text NOT NULL UNIQUE,
    name        text NOT NULL,
    sort_order  integer NOT NULL,
    is_terminal boolean NOT NULL DEFAULT false
);

CREATE SEQUENCE cases.case_number_seq;

CREATE TABLE cases.cases (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_number             text NOT NULL UNIQUE,
    client_user_id          uuid NOT NULL REFERENCES identity.users (id),
    organization_id         uuid REFERENCES identity.organizations (id),
    assigned_to             uuid REFERENCES identity.users (id),
    category_id             uuid REFERENCES catalog.service_categories (id),
    service_id              uuid REFERENCES catalog.services (id),
    package_id              uuid REFERENCES catalog.packages (id),
    authority_id            uuid REFERENCES authorities.authorities (id),
    status_id               uuid NOT NULL REFERENCES cases.case_statuses (id),
    priority                cases.case_priority NOT NULL DEFAULT 'normal',
    preferred_language_code text NOT NULL DEFAULT 'en' REFERENCES catalog.languages (code),
    title                   text,
    problem_summary         text,
    desired_outcome         text,
    success_metric          text,
    incident_at             timestamptz,
    incident_location       text,
    sla_due_at              timestamptz,
    submitted_at            timestamptz,
    closed_at               timestamptz,
    reopened_at             timestamptz,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    deleted_at              timestamptz
);

CREATE TABLE cases.case_services (
    case_id     uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    service_id  uuid NOT NULL REFERENCES catalog.services (id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (case_id, service_id)
);

CREATE TABLE cases.case_parties (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    party_role      cases.party_role NOT NULL,
    full_name       text NOT NULL,
    relation_note   text,
    contact         text,
    address_line    text,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cases.case_events (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    occurred_at     timestamptz NOT NULL,
    title           text NOT NULL,
    description     text,
    sort_order      integer NOT NULL DEFAULT 0,
    created_by      uuid REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cases.case_tasks (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    title           text NOT NULL,
    assignee_id     uuid REFERENCES identity.users (id),
    due_at          timestamptz,
    completed_at    timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cases.case_notes (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    author_id       uuid NOT NULL REFERENCES identity.users (id),
    body            text NOT NULL,
    is_internal     boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE cases.case_timeline (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    event_type      text NOT NULL,
    summary         text NOT NULL,
    payload         jsonb NOT NULL DEFAULT '{}'::jsonb,
    actor_id        uuid REFERENCES identity.users (id),
    occurred_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER cases_set_updated_at
    BEFORE UPDATE ON cases.cases
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER case_tasks_set_updated_at
    BEFORE UPDATE ON cases.case_tasks
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
