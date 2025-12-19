-- Check the status of the index build
-- Updates:
SELECT
    age(clock_timestamp(), a.query_start) AS duration,
    a.query,
    p.phase,
    round(p.blocks_done / NULLIF(p.blocks_total::numeric, 0) * 100, 2) AS "% blocks done",
    p.blocks_total,
    p.blocks_done,
    round(p.tuples_done / NULLIF(p.tuples_total::numeric, 0) * 100, 2) AS "% tuples done",
    p.tuples_total,
    p.tuples_done,
    p.command,
    p.lockers_total,
    p.lockers_done,
    p.current_locker_pid,
    index_relid::regclass AS index_name,
    relid::regclass AS table_name,
    pg_size_pretty(pg_relation_size(relid)) AS table_size,
    a.pid
FROM
    pg_stat_progress_create_index p
JOIN
    pg_stat_activity a ON p.pid = a.pid;
