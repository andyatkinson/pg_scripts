-- from crunchy data
SELECT
    total_exec_time,
    mean_exec_time AS avg_ms,
    calls,
    query
FROM
    pg_stat_statements
ORDER BY
    mean_exec_time DESC
LIMIT 10;

-- OR:
--
SELECT
    mean_time,
    calls,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written,
    temp_blks_written
    query
FROM
    pg_stat_statements
ORDER BY
    mean_time DESC
LIMIT 5;
