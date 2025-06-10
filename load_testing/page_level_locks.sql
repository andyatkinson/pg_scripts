-- Vacuum will typically acquire AccessShareLock and CleanupLock.
-- A high count of locks on your test table is a red flag under pressure.
SELECT
    now(),
    relation::regclass AS table_name,
    mode,
    COUNT(*) AS lock_count
FROM
    pg_locks
WHERE
    relation IS NOT NULL
GROUP BY
    relation,
    mode;
