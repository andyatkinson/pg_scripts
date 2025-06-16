-- Vacuum: https://www.postgresql.org/docs/current/sql-vacuum.html
-- check pg_locks
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

-- FREEZE
-- Selects aggressive “freezing” of tuples.
-- Specifying FREEZE is equivalent to performing VACUUM with
-- the vacuum_freeze_min_age and vacuum_freeze_table_age parameters set to zero.
-- Aggressive freezing is always performed when the table is rewritten, 
-- so this option is redundant when FULL is specified.


