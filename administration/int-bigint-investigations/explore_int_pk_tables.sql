SELECT
    n.nspname AS table_schema,
    c.relname AS table_name,
    a.attname AS column_name,
    pg_catalog.format_type(a.atttypid, a.atttypmod) AS data_type,
    c.reltuples::numeric AS estimate
FROM
    pg_catalog.pg_constraint con
    JOIN pg_catalog.pg_class c ON con.conrelid = c.oid
    JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
    JOIN pg_catalog.pg_attribute a ON a.attnum = ANY (con.conkey)
        AND a.attrelid = c.oid
WHERE
    con.contype = 'p' -- Primary key constraint
    AND n.nspname NOT IN ('pg_catalog', 'information_schema') -- Exclude system schemas
    AND pg_catalog.format_type(a.atttypid, a.atttypmod) = 'integer'::text
ORDER BY
    5 DESC;
