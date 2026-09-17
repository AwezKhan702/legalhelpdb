INSERT INTO authorities.authority_types (code, name) VALUES
    ('police_station', 'Police Station'),
    ('police_authority', 'Police authority'),
    ('government_department', 'Government department'),
    ('municipal', 'Municipal authority'),
    ('revenue', 'Revenue authority'),
    ('labour', 'Labour authority'),
    ('banking_regulatory', 'Banking/regulatory authority'),
    ('rti', 'RTI authority'),
    ('court', 'Court'),
    ('tribunal', 'Tribunal'),
    ('legal_services', 'Legal Services Authority')
ON CONFLICT (code) DO NOTHING;
