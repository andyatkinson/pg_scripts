-- List tables with no foreign key columns/foreign key constraints
-- These are "root" or "parent" tables
SELECT
    tablename
FROM
    pg_tables
WHERE
    schemaname = 'public'
    AND tablename NOT IN ( SELECT DISTINCT
            conrelid::regclass::text
        FROM
            pg_constraint
        WHERE
            contype = 'f');

