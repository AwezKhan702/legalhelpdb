INSERT INTO catalog.languages (code, name, is_ui, is_document) VALUES
    ('en', 'English', true, true),
    ('hi', 'Hindi', true, true),
    ('mr', 'Marathi', true, true)
ON CONFLICT (code) DO NOTHING;
