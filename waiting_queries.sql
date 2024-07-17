SELECT
    pid,
    wait_event_type,
    wait_event,
    LEFT (query,
        60) AS query,
    backend_start,
    query_start,
    (CURRENT_TIMESTAMP - query_start) AS ago
FROM
    pg_stat_activity
WHERE
    datname = 'rideshare_development';
