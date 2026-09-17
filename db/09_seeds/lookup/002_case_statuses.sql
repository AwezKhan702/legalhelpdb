INSERT INTO cases.case_statuses (code, name, sort_order, is_terminal) VALUES
    ('new', 'New', 10, false),
    ('information_required', 'Information Required', 20, false),
    ('documents_pending', 'Documents Pending', 30, false),
    ('under_assessment', 'Under Assessment', 40, false),
    ('consultation_scheduled', 'Consultation Scheduled', 50, false),
    ('consultation_completed', 'Consultation Completed', 60, false),
    ('drafting', 'Drafting', 70, false),
    ('internal_review', 'Internal Review', 80, false),
    ('client_review', 'Client Review', 90, false),
    ('revision_requested', 'Revision Requested', 100, false),
    ('final_draft', 'Final Draft', 110, false),
    ('submitted', 'Submitted', 120, false),
    ('awaiting_response', 'Awaiting Response', 130, false),
    ('follow_up_required', 'Follow-up Required', 140, false),
    ('escalation_required', 'Escalation Required', 150, false),
    ('closed', 'Closed', 160, true),
    ('reopened', 'Reopened', 170, false)
ON CONFLICT (code) DO NOTHING;
