-- We want to find the number of hot updates
-- for all tables, but focus on tables with a high UPDATE
-- rate and high value tables

-- For rideshare, scope this to the 'rideshare' schema
SELECT
    schemaname,
    relname,
    n_tup_hot_upd
FROM
    pg_stat_all_tables
WHERE
    schemaname = 'rideshare'
ORDER BY
    n_tup_hot_upd DESC;

-- Check the "n_tup_hot_upd" field tables

-- For those tables, check the indexes
-- Check pg_stat_statements for update statements in that table
SELECT
    nspname AS schema_name,
    relname AS table_name,
    CASE WHEN array_length(reloptions, 1) IS NULL THEN
        '100' -- Default fillfactor value
    ELSE
        (
            SELECT
                substring(reloptions[i] FROM 12) -- Extract the fillfactor value
            FROM
                generate_series(array_lower(reloptions, 1), array_upper(reloptions, 1)) AS s (i)
            WHERE
                reloptions[i] LIKE 'fillfactor%')
    END AS fillfactor
FROM
    pg_class
    JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE
    relkind = 'r' -- 'r' is for ordinary tables
    AND nspname = 'rideshare'
ORDER BY
    schema_name,
    table_name;


-- Using "users" table as an example, with a default fillfactor
-- of 100, let's lower it to 80
ALTER TABLE rideshare.users SET (fillfactor = 80);

-- To rebuild the table, run a VACUUM FULL
VACUUM (FULL, VERBOSE) rideshare.users;

-- INFO:  vacuuming "rideshare.users"
-- INFO:  "rideshare.users": found 1 removable, 20210 nonremovable row versions in 332 pages
-- DETAIL:  0 dead row versions cannot be removed yet.
-- CPU: user: 0.01 s, system: 0.00 s, elapsed: 0.03 s.
-- VACUUM

-- Make sure the fillfactor has changed
