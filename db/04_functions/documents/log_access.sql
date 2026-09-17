CREATE OR REPLACE FUNCTION documents.log_document_access()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO documents.document_access_logs (document_id, actor_id, action)
    VALUES (NEW.document_id, NEW.uploaded_by, 'version_uploaded');
    RETURN NEW;
END;
$$;
