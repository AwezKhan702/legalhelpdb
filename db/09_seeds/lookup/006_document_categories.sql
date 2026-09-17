INSERT INTO documents.document_categories (code, name) VALUES
    ('identity', 'Identity'),
    ('complaint', 'Complaint'),
    ('notice', 'Notice'),
    ('reply', 'Reply'),
    ('agreement', 'Agreement'),
    ('bank', 'Bank document'),
    ('employment', 'Employment document'),
    ('government', 'Government communication'),
    ('police', 'Police document'),
    ('court', 'Court document'),
    ('evidence', 'Evidence'),
    ('photograph', 'Photograph'),
    ('av_reference', 'Audio/video reference'),
    ('other', 'Other')
ON CONFLICT (code) DO NOTHING;
