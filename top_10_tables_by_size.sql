-- Top 10 largest by size, excluding some
-- internal schemas
SELECT
    table_schema || '.' || table_name AS table_full_name,
    pg_total_relation_size(table_schema || '.' || table_name) AS total_size,
    pg_size_pretty(pg_total_relation_size(table_schema || '.' || table_name)) AS total_size_pretty
FROM
    information_schema.tables
WHERE
    table_type = 'BASE TABLE'
    AND table_schema NOT IN ('pg_catalog', 'information_schema', 'temp')
ORDER BY
    pg_total_relation_size(table_schema || '.' || table_name) DESC
LIMIT 10;
