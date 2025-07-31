-- Longer than 2 seconds
SELECT
    pid,
    usename,
    state,
    query,
    query_start,
    now() - query_start AS duration
FROM
    pg_stat_activity
WHERE
    state IN ('active', 'idle in transaction')
    AND now() - query_start > interval '2 seconds'
ORDER BY
    query_start;
