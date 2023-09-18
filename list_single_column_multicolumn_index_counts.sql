-- https://wiki.postgresql.org/wiki/Index_Maintenance
SELECT
    pg_class.relname,
    COUNT(*) FILTER ( WHERE indnatts = 1 )                AS single_column_indexes,
    COUNT(*) FILTER ( WHERE indnatts IS DISTINCT FROM 1 ) AS multi_column_indexes
FROM
    pg_namespace
    LEFT JOIN pg_class ON pg_namespace.oid = pg_class.relnamespace
    LEFT JOIN pg_index ON pg_class.oid = pg_index.indrelid
WHERE
    pg_namespace.nspname = 'public' AND
    pg_class.relkind = 'r'
GROUP BY pg_class.relname, pg_class.reltuples
ORDER BY pg_class.reltuples DESC;
