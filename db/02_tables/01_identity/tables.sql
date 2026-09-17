-- USER, USER_ROLE, CLIENT_PROFILE, ORGANIZATION (FSD §7, §34, §42)

CREATE TABLE identity.roles (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code            text NOT NULL UNIQUE,
    name            text NOT NULL,
    description     text,
    is_staff        boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE identity.users (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email                   citext UNIQUE,
    mobile                  text UNIQUE,
    password_hash           text,
    full_name               text NOT NULL,
    preferred_language_code text NOT NULL DEFAULT 'en',
    communication_preference comms.channel,
    is_active               boolean NOT NULL DEFAULT true,
    mfa_enabled             boolean NOT NULL DEFAULT false,
    email_verified_at       timestamptz,
    mobile_verified_at      timestamptz,
    last_login_at           timestamptz,
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    deleted_at              timestamptz,
    CONSTRAINT users_email_or_mobile CHECK (email IS NOT NULL OR mobile IS NOT NULL)
);

CREATE TABLE identity.user_roles (
    user_id     uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    role_id     uuid NOT NULL REFERENCES identity.roles (id) ON DELETE RESTRICT,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    assigned_by uuid REFERENCES identity.users (id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE identity.auth_identities (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    provider            identity.auth_provider NOT NULL,
    provider_subject    text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    UNIQUE (provider, provider_subject)
);

CREATE TABLE identity.otp_challenges (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid REFERENCES identity.users (id) ON DELETE CASCADE,
    channel         comms.channel NOT NULL,
    destination     text NOT NULL,
    code_hash       text NOT NULL,
    expires_at      timestamptz NOT NULL,
    consumed_at     timestamptz,
    attempt_count   integer NOT NULL DEFAULT 0,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE identity.sessions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    refresh_token_hash text NOT NULL,
    device_label    text,
    ip_address      inet,
    user_agent      text,
    expires_at      timestamptz NOT NULL,
    revoked_at      timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE identity.organizations (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name            text NOT NULL,
    org_type        identity.client_type NOT NULL DEFAULT 'business',
    gstin           text,
    pan             text,
    address_line    text,
    city            text,
    district        text,
    state           text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    deleted_at      timestamptz
);

CREATE TABLE identity.organization_members (
    organization_id uuid NOT NULL REFERENCES identity.organizations (id) ON DELETE CASCADE,
    user_id         uuid NOT NULL REFERENCES identity.users (id) ON DELETE CASCADE,
    member_role     text NOT NULL DEFAULT 'member',
    created_at      timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (organization_id, user_id)
);

CREATE TABLE identity.client_profiles (
    user_id         uuid PRIMARY KEY REFERENCES identity.users (id) ON DELETE CASCADE,
    organization_id uuid REFERENCES identity.organizations (id),
    client_type     identity.client_type NOT NULL DEFAULT 'individual',
    address_line    text,
    city            text,
    district        text,
    state           text,
    kyc_status      identity.kyc_status NOT NULL DEFAULT 'pending',
    consent_at      timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE identity.staff_profiles (
    user_id         uuid PRIMARY KEY REFERENCES identity.users (id) ON DELETE CASCADE,
    employee_code   text UNIQUE,
    title           text,
    is_available    boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER users_set_updated_at
    BEFORE UPDATE ON identity.users
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER organizations_set_updated_at
    BEFORE UPDATE ON identity.organizations
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER client_profiles_set_updated_at
    BEFORE UPDATE ON identity.client_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER staff_profiles_set_updated_at
    BEFORE UPDATE ON identity.staff_profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
