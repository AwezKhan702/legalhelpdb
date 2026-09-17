DO $$
DECLARE
    sch text;
    typ text;
BEGIN
    FOREACH sch IN ARRAY ARRAY[
        'identity', 'catalog', 'authorities', 'cases', 'documents',
        'consultations', 'drafts', 'billing', 'comms', 'followups',
        'research', 'content', 'audit'
    ]
    LOOP
        EXECUTE format('GRANT USAGE ON SCHEMA %I TO legalhelp_migrate, legalhelp_app, legalhelp_readonly', sch);
        EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO legalhelp_migrate', sch);
        EXECUTE format('GRANT ALL ON ALL SEQUENCES IN SCHEMA %I TO legalhelp_migrate', sch);
        EXECUTE format('GRANT ALL ON ALL FUNCTIONS IN SCHEMA %I TO legalhelp_migrate', sch);
        EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA %I TO legalhelp_app', sch);
        EXECUTE format('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO legalhelp_app', sch);
        EXECUTE format('GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %I TO legalhelp_app', sch);
        EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO legalhelp_readonly', sch);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO legalhelp_app', sch);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO legalhelp_readonly', sch);
        EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT EXECUTE ON FUNCTIONS TO legalhelp_app', sch);

        FOR typ IN
            SELECT t.typname
            FROM pg_type t
            JOIN pg_namespace n ON n.oid = t.typnamespace
            WHERE n.nspname = sch
              AND t.typtype = 'e'
        LOOP
            EXECUTE format(
                'GRANT USAGE ON TYPE %I.%I TO legalhelp_app, legalhelp_readonly',
                sch,
                typ
            );
        END LOOP;
    END LOOP;
END
$$;
