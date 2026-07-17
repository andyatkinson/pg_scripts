-- run "analyze" to analyze all tables
SELECT
    schemaname,
    tablename,
    attname AS column,
    n_distinct,
    CASE WHEN n_distinct >= 0 THEN
        n_distinct::text
    ELSE
        ('~' || (- n_distinct * rel.reltuples)) -- negative means "estimated fraction of table"
    END AS estimated_distinct,
    rel.reltuples::numeric AS estimated_rows
FROM
    pg_stats s
    JOIN pg_class rel ON rel.relname = s.tablename
    JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
        AND nsp.nspname = s.schemaname
WHERE
    n_distinct IS NOT NULL
AND schemaname NOT IN ('pg_catalog','information_schema')
ORDER BY
    ABS(n_distinct) DESC
LIMIT 10;
