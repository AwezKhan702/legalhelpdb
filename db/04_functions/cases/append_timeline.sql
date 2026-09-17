CREATE OR REPLACE FUNCTION cases.append_timeline()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO cases.case_timeline (case_id, event_type, summary, actor_id, payload)
        VALUES (
            NEW.id,
            'case.created',
            'Case created',
            NEW.client_user_id,
            jsonb_build_object('case_number', NEW.case_number)
        );
    ELSIF TG_OP = 'UPDATE' AND NEW.status_id IS DISTINCT FROM OLD.status_id THEN
        INSERT INTO cases.case_timeline (case_id, event_type, summary, actor_id, payload)
        VALUES (
            NEW.id,
            'case.status_changed',
            'Case status changed',
            NEW.assigned_to,
            jsonb_build_object('from', OLD.status_id, 'to', NEW.status_id)
        );
    END IF;
    RETURN NEW;
END;
$$;
