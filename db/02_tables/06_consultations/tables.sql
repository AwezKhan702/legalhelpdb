-- CONSULTATION, APPOINTMENT, CONSULTATION_NOTE, CONSULTATION_SUMMARY (FSD §10, §42)

CREATE TABLE consultations.consultations (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid REFERENCES cases.cases (id) ON DELETE SET NULL,
    client_user_id  uuid NOT NULL REFERENCES identity.users (id),
    consultant_id   uuid REFERENCES identity.users (id),
    consultation_type consultations.consultation_type NOT NULL,
    status          consultations.appointment_status NOT NULL DEFAULT 'requested',
    scheduled_at    timestamptz,
    duration_minutes integer,
    meeting_url     text,
    location        text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE consultations.appointments (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id     uuid NOT NULL REFERENCES consultations.consultations (id) ON DELETE CASCADE,
    starts_at           timestamptz NOT NULL,
    ends_at             timestamptz NOT NULL,
    status              consultations.appointment_status NOT NULL DEFAULT 'scheduled',
    cancelled_reason    text,
    created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE consultations.consultation_notes (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id     uuid NOT NULL REFERENCES consultations.consultations (id) ON DELETE CASCADE,
    author_id           uuid NOT NULL REFERENCES identity.users (id),
    body                text NOT NULL,
    is_internal         boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE consultations.consultation_summaries (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    consultation_id     uuid NOT NULL UNIQUE REFERENCES consultations.consultations (id) ON DELETE CASCADE,
    summary             text NOT NULL,
    recommended_next_steps text,
    created_by          uuid REFERENCES identity.users (id),
    created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER consultations_set_updated_at
    BEFORE UPDATE ON consultations.consultations
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
