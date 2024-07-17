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
