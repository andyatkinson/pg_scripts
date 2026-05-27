-- For each table
-- Lists the relfrozenxid (including associated toast table)
-- And whether it's over the current value of vacuum_freeze_table_age
-- (vacuum_freeze_table_age default is 150,000,000)
SELECT
    c.oid::regclass AS table_name,
    greatest (age(c.relfrozenxid), age(t.relfrozenxid)) AS age_transactions,
    current_setting('vacuum_freeze_table_age')::integer AS freeze_age_limit,
    (greatest (age(c.relfrozenxid), age(t.relfrozenxid)) > current_setting('vacuum_freeze_table_age')::integer) AS is_over_limit
FROM
    pg_class c
    LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE
    c.relkind IN ('r', 'm') -- tables and materialized views
    AND c.oid::regclass::text NOT LIKE 'pg_%'
ORDER BY
    age_transactions DESC;
