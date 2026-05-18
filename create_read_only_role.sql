-- Creating a read only role for ad hoc querying
CREATE ROLE app_read_only LOGIN PASSWORD '<some secure password>';
REVOKE ALL ON SCHEMA public FROM app_read_only;
GRANT USAGE ON SCHEMA public TO app_read_only; -- schema usage
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read_only; -- select on all tables

-- Run "\ds" to check if sequences are used, if so grant this
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_read_only;

-- There are functions (run "\df" to check) that may be needed
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_read_only;

-- Run as table creator user (confirmed with "\dt" "Owner" column) this is what "select current_user" is
-- Use predefined role "pg_read_all_data" vs. altering default privileges due to a variety of table-creator roles below
GRANT pg_read_all_data TO app_read_only;
