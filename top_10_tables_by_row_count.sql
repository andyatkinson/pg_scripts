SELECT
    table_schema || '.' || table_name AS table_full_name,
    reltuples::bigint AS row_count
FROM
    pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    JOIN information_schema.tables t ON t.table_schema = n.nspname
        AND t.table_name = c.relname
WHERE
    t.table_type = 'BASE TABLE'
    AND t.table_schema NOT IN ('pg_catalog', 'information_schema', 'temp')
ORDER BY
    reltuples DESC
LIMIT 10;
