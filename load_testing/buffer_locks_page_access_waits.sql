-- Buffer Locks / Page Access Waits (Query-Vacuum Contention)
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
