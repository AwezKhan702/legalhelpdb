INSERT INTO catalog.packages (code, name, description, revision_limit) VALUES
    ('assessment', 'Legal Problem Assessment', 'Consultation, document review, issue classification and written next-step summary', 0),
    ('complaint_drafting', 'Complaint Drafting', 'Fact collection, document review, draft complaint, one revision, final PDF/Word', 1),
    ('rti_complete', 'RTI Complete Support', 'Issue assessment, information request, RTI draft, review, submission guidance, follow-up reminder', 1),
    ('legal_notice', 'Legal Notice', 'Consultation, document review, legal notice draft, revision, final document, dispatch assistance', 1)
ON CONFLICT (code) DO NOTHING;
