-- https://dba.stackexchange.com/a/23837
select table_name from INFORMATION_SCHEMA.views WHERE table_schema = ANY (current_schemas(false));
