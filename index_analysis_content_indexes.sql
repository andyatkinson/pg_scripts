-- Indexes in 'public' schema that are
-- "content" indexes, i.e. they aren't system indexes
-- for primary keys, unique constraints
SELECT
    n.nspname AS schema_name,
    c.relname AS index_name,
    t.relname AS table_name,
    pg_index.indisunique AS is_unique,
    pg_index.indisprimary AS is_primary
FROM
    pg_index
    JOIN pg_class c ON c.oid = pg_index.indexrelid
    JOIN pg_class t ON t.oid = pg_index.indrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
WHERE
    n.nspname = 'public'
    AND NOT pg_index.indisunique
    AND NOT pg_index.indisprimary;


-- Join to pg_constraint
-- to exclude foreign key constraint indexes
SELECT
    n.nspname AS schema_name,
    c.relname AS index_name,
    t.relname AS table_name
FROM
    pg_index
JOIN
    pg_class c ON c.oid = pg_index.indexrelid
JOIN
    pg_class t ON t.oid = pg_index.indrelid
JOIN
    pg_namespace n ON n.oid = t.relnamespace
LEFT JOIN
    pg_constraint con ON con.conindid = pg_index.indexrelid
WHERE
    n.nspname = 'public'
-- https://mohyusufz.medium.com/how-to-check-for-indexes-on-foreign-key-columns-in-postgresql-450159772f8e#:~:text=Checking%20for%20Indexes%3A,%2C%20it%20displays%20%22Unindexed.%22
    AND NOT pg_index.indisprimary
    AND con.contype IS NULL; -- Excludes indexes associated with constraints


-- Find foreign key indexes
-- Credit: https://mohyusufz.medium.com/how-to-check-for-indexes-on-foreign-key-columns-in-postgresql-450159772f8e
WITH fk_constraints AS (
    SELECT
        c.conrelid::regclass AS table,
        c.conname AS constraint,
        string_agg(a.attname, ',' ORDER BY x.n) AS columns,
        pg_catalog.pg_size_pretty(pg_catalog.pg_relation_size(c.conrelid)) AS size,
        c.confrelid::regclass AS referenced_table,
        c.conkey AS conkey,
        c.conrelid AS conrelid
    FROM
        pg_catalog.pg_constraint c
        /* Enumerated key column numbers per foreign key */
        CROSS JOIN LATERAL unnest(c.conkey)
        WITH ORDINALITY AS x (attnum, n)
        /* Join to get the column names */
        JOIN pg_catalog.pg_attribute a ON a.attnum = x.attnum
            AND a.attrelid = c.conrelid
    WHERE
        /* Ensure the constraint is a foreign key */
        c.contype = 'f'
    GROUP BY
        c.conrelid,
        c.conname,
        c.confrelid,
        c.conkey
)
SELECT
    fk.table,
    fk.constraint,
    fk.columns,
    fk.size,
    fk.referenced_table,
    /* Retrieve the index name or mark as Unindexed */
    COALESCE((
        SELECT
            i.indexrelid::regclass::text
        FROM pg_catalog.pg_index i
        WHERE
            i.indrelid = fk.conrelid
            AND i.indpred IS NULL
            AND (i.indkey::smallint[])[0:cardinality(fk.conkey) - 1] OPERATOR (pg_catalog. @>) fk.conkey LIMIT 1), 'Unindexed') AS index_name
FROM
    fk_constraints fk
ORDER BY
    pg_catalog.pg_relation_size(fk.conrelid) DESC;
