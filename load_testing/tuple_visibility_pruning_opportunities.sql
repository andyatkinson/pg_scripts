-- Use this to correlate dead tuple buildup with vacuum timing and CPU load.
SELECT
    now(),
    relname,
    n_dead_tup,
    n_live_tup,
    vacuum_count,
    autovacuum_count
FROM
    pg_stat_user_tables
WHERE
    relname = 'trips';
