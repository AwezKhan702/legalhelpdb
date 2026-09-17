-- PAYMENT, INVOICE, TRANSACTION, REFUND (FSD §13, §42)

CREATE TABLE billing.invoices (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number  text NOT NULL UNIQUE,
    case_id         uuid REFERENCES cases.cases (id),
    client_user_id  uuid NOT NULL REFERENCES identity.users (id),
    service_id      uuid REFERENCES catalog.services (id),
    package_id      uuid REFERENCES catalog.packages (id),
    amount          numeric(12, 2) NOT NULL,
    tax_amount      numeric(12, 2) NOT NULL DEFAULT 0,
    currency        text NOT NULL DEFAULT 'INR',
    status          billing.payment_status NOT NULL DEFAULT 'pending',
    issued_at       timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE billing.payments (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id      uuid NOT NULL REFERENCES billing.invoices (id),
    case_id         uuid REFERENCES cases.cases (id),
    client_user_id  uuid NOT NULL REFERENCES identity.users (id),
    method          billing.payment_method,
    status          billing.payment_status NOT NULL DEFAULT 'pending',
    amount          numeric(12, 2) NOT NULL,
    currency        text NOT NULL DEFAULT 'INR',
    gateway         text,
    gateway_order_id text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE billing.transactions (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id      uuid NOT NULL REFERENCES billing.payments (id) ON DELETE CASCADE,
    gateway_txn_id  text,
    status          billing.payment_status NOT NULL,
    raw_payload     jsonb,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE billing.refunds (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id      uuid NOT NULL REFERENCES billing.payments (id),
    amount          numeric(12, 2) NOT NULL,
    reason          text,
    status          billing.payment_status NOT NULL DEFAULT 'pending',
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER payments_set_updated_at
    BEFORE UPDATE ON billing.payments
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
