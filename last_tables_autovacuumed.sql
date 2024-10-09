SELECT
    relname,
    last_vacuum,
    last_autovacuum
FROM
    pg_stat_user_tables
WHERE
    last_autovacuum IS NOT NULL
ORDER BY
    last_autovacuum DESC
LIMIT 10;
