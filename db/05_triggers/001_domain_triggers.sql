CREATE TRIGGER cases_set_case_number
    BEFORE INSERT ON cases.cases
    FOR EACH ROW EXECUTE FUNCTION cases.set_case_number();

CREATE TRIGGER cases_append_timeline
    AFTER INSERT OR UPDATE ON cases.cases
    FOR EACH ROW EXECUTE FUNCTION cases.append_timeline();

CREATE TRIGGER document_versions_log_access
    AFTER INSERT ON documents.document_versions
    FOR EACH ROW EXECUTE FUNCTION documents.log_document_access();
