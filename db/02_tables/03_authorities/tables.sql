-- AUTHORITY directory (FSD §18, §19)

CREATE TABLE authorities.authority_types (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code        text NOT NULL UNIQUE,
    name        text NOT NULL
);

CREATE TABLE authorities.authorities (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_type_id   uuid NOT NULL REFERENCES authorities.authority_types (id),
    name                text NOT NULL,
    address_line        text,
    city                text,
    district            text,
    state               text,
    jurisdiction        text,
    phone               text,
    email               text,
    website             text,
    submission_method   text,
    is_active           boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE authorities.authority_services (
    authority_id    uuid NOT NULL REFERENCES authorities.authorities (id) ON DELETE CASCADE,
    service_id      uuid NOT NULL REFERENCES catalog.services (id) ON DELETE CASCADE,
    PRIMARY KEY (authority_id, service_id)
);

CREATE TRIGGER authorities_set_updated_at
    BEFORE UPDATE ON authorities.authorities
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
