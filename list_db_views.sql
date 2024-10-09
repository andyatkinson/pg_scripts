-- https://dba.stackexchange.com/a/23837
SELECT
    table_name
FROM
    information_schema.views
WHERE
    table_schema = ANY(current_schemas(FALSE));
