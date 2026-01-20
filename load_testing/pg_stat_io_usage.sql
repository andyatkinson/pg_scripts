-- https://www.postgresql.org/docs/current/monitoring-stats.html
-- pg_stat_io autovacuum
SELECT
    *
FROM
    pg_stat_io
WHERE
    backend_type = 'autovacuum worker'
    OR (context = 'vacuum'
        AND (reads <> 0
            OR writes <> 0
            OR extends <> 0));

-- pg_stat_io background writer
SELECT * FROM pg_stat_io
WHERE backend_type = 'BackgroundWriter';
