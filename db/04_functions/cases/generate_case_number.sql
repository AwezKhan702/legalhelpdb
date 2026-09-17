-- Generates LGL-YYYY-NNNNNN case numbers (FSD §6).
CREATE OR REPLACE FUNCTION cases.generate_case_number()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    next_n bigint;
BEGIN
    next_n := nextval('cases.case_number_seq');
    RETURN format('LGL-%s-%s', to_char(now(), 'YYYY'), lpad(next_n::text, 6, '0'));
END;
$$;

CREATE OR REPLACE FUNCTION cases.set_case_number()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.case_number IS NULL OR btrim(NEW.case_number) = '' THEN
        NEW.case_number := cases.generate_case_number();
    END IF;
    RETURN NEW;
END;
$$;
