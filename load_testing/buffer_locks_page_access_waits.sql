-- Investigation: Query-vacuum contention
-- Buffer Locks / Page Access Waits
SELECT
    now(),
    pid,
    usename,
    wait_event_type,
    wait_event,
    query
FROM
    pg_stat_activity
WHERE
    wait_event IS NOT NULL
    AND state != 'idle';
