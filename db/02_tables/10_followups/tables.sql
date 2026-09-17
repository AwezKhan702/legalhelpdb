-- FOLLOW_UP (FSD §17, §42)

CREATE TABLE followups.follow_ups (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid NOT NULL REFERENCES cases.cases (id) ON DELETE CASCADE,
    followup_type   followups.followup_type NOT NULL,
    title           text NOT NULL,
    due_at          timestamptz NOT NULL,
    assigned_to     uuid REFERENCES identity.users (id),
    completed_at    timestamptz,
    completion_note text,
    created_by      uuid REFERENCES identity.users (id),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER follow_ups_set_updated_at
    BEFORE UPDATE ON followups.follow_ups
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
