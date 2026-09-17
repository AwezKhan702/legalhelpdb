INSERT INTO identity.roles (code, name, description, is_staff) VALUES
    ('super_admin', 'Super Admin', 'Full access', true),
    ('case_manager', 'Case Manager', 'Case, customer and document access', true),
    ('legal_drafting_sme', 'Legal Drafting SME', 'Assigned cases and documents', true),
    ('researcher', 'Researcher', 'Research-assigned cases only', true),
    ('advocate', 'Advocate', 'Assigned matters', true),
    ('finance', 'Finance', 'Payments and invoices only', true),
    ('support', 'Support', 'Limited client and case access', true),
    ('client', 'Client', 'Own matters only', false)
ON CONFLICT (code) DO NOTHING;
