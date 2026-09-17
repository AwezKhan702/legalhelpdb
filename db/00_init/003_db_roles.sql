-- Application database roles. Passwords are for local/dev only; override in production.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'legalhelp_migrate') THEN
        CREATE ROLE legalhelp_migrate LOGIN PASSWORD 'legalhelp_migrate';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'legalhelp_app') THEN
        CREATE ROLE legalhelp_app LOGIN PASSWORD 'legalhelp_app';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'legalhelp_readonly') THEN
        CREATE ROLE legalhelp_readonly LOGIN PASSWORD 'legalhelp_readonly';
    END IF;

    EXECUTE format(
        'GRANT CONNECT ON DATABASE %I TO legalhelp_migrate, legalhelp_app, legalhelp_readonly',
        current_database()
    );
END
$$;

GRANT USAGE ON SCHEMA public TO legalhelp_migrate, legalhelp_app, legalhelp_readonly;
