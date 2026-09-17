-- NOTIFICATION and MESSAGE (FSD §29, §38, §42)

CREATE TABLE comms.messages (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    case_id         uuid REFERENCES cases.cases (id) ON DELETE CASCADE,
    sender_id       uuid NOT NULL REFERENCES identity.users (id),
    body            text NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE comms.message_recipients (
    message_id      uuid NOT NULL REFERENCES comms.messages (id) ON DELETE CASCADE,
    user_id         uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    read_at         timestamptz,
    PRIMARY KEY (message_id, user_id)
);

CREATE TABLE comms.notifications (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    case_id         uuid REFERENCES cases.cases (id) ON DELETE SET NULL,
    channel         comms.channel NOT NULL,
    template_code   text NOT NULL,
    title           text,
    body            text NOT NULL,
    payload         jsonb NOT NULL DEFAULT '{}'::jsonb,
    sent_at         timestamptz,
    read_at         timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE comms.notification_preferences (
    user_id     uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    channel     comms.channel NOT NULL,
    enabled     boolean NOT NULL DEFAULT true,
    PRIMARY KEY (user_id, channel)
);
