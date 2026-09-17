-- SERVICE, PACKAGE, PRICING (FSD §5, §11, §12, §65)

CREATE TABLE catalog.languages (
    code        text PRIMARY KEY,
    name        text NOT NULL,
    is_ui       boolean NOT NULL DEFAULT true,
    is_document boolean NOT NULL DEFAULT true
);

CREATE TABLE catalog.service_categories (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code        text NOT NULL UNIQUE,
    name        text NOT NULL,
    parent_id   uuid REFERENCES catalog.service_categories (id),
    sort_order  integer NOT NULL DEFAULT 0,
    is_active   boolean NOT NULL DEFAULT true,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE catalog.services (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id     uuid NOT NULL REFERENCES catalog.service_categories (id),
    code            text NOT NULL UNIQUE,
    name            text NOT NULL,
    description     text,
    default_sla_hours integer,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE catalog.packages (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    code            text NOT NULL UNIQUE,
    name            text NOT NULL,
    description     text,
    base_amount     numeric(12, 2) NOT NULL DEFAULT 0,
    currency        text NOT NULL DEFAULT 'INR',
    revision_limit  integer NOT NULL DEFAULT 1,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE catalog.package_items (
    package_id      uuid NOT NULL REFERENCES catalog.packages (id) ON DELETE CASCADE,
    service_id      uuid NOT NULL REFERENCES catalog.services (id),
    quantity        integer NOT NULL DEFAULT 1,
    PRIMARY KEY (package_id, service_id)
);

CREATE TABLE catalog.pricing_rules (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    service_id      uuid REFERENCES catalog.services (id),
    package_id      uuid REFERENCES catalog.packages (id),
    client_type     identity.client_type,
    amount          numeric(12, 2) NOT NULL,
    currency        text NOT NULL DEFAULT 'INR',
    effective_from  date NOT NULL DEFAULT CURRENT_DATE,
    effective_to    date,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT pricing_target CHECK (service_id IS NOT NULL OR package_id IS NOT NULL)
);

CREATE TRIGGER services_set_updated_at
    BEFORE UPDATE ON catalog.services
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER packages_set_updated_at
    BEFORE UPDATE ON catalog.packages
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
