-- Closed value sets from the functional specification.

CREATE TYPE identity.client_type AS ENUM (
    'individual',
    'family',
    'business',
    'advocate',
    'ngo'
);

CREATE TYPE identity.kyc_status AS ENUM (
    'pending',
    'submitted',
    'verified',
    'rejected'
);

CREATE TYPE identity.auth_provider AS ENUM (
    'otp',
    'password',
    'google',
    'apple',
    'guest'
);

CREATE TYPE cases.case_priority AS ENUM (
    'low',
    'normal',
    'high',
    'urgent',
    'critical'
);

CREATE TYPE cases.party_role AS ENUM (
    'client',
    'opponent',
    'witness',
    'authority',
    'advocate',
    'other'
);

CREATE TYPE consultations.consultation_type AS ENUM (
    'phone',
    'video',
    'in_person',
    'document_based',
    'written_opinion'
);

CREATE TYPE consultations.appointment_status AS ENUM (
    'requested',
    'scheduled',
    'completed',
    'cancelled',
    'no_show'
);

CREATE TYPE drafts.draft_status AS ENUM (
    'drafting',
    'internal_review',
    'client_review',
    'revision_requested',
    'approved',
    'final'
);

CREATE TYPE billing.payment_status AS ENUM (
    'pending',
    'initiated',
    'successful',
    'failed',
    'refunded',
    'partially_refunded'
);

CREATE TYPE billing.payment_method AS ENUM (
    'upi',
    'credit_card',
    'debit_card',
    'net_banking',
    'wallet'
);

CREATE TYPE comms.channel AS ENUM (
    'in_app',
    'push',
    'sms',
    'email',
    'whatsapp'
);

CREATE TYPE followups.followup_type AS ENUM (
    'rti_response',
    'complaint',
    'notice_response',
    'document_submission',
    'consultation',
    'client_action',
    'authority_response',
    'escalation',
    'hearing'
);

CREATE TYPE documents.retention_state AS ENUM (
    'active',
    'closed',
    'archived',
    'legal_hold',
    'pending_deletion'
);
