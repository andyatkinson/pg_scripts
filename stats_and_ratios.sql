-- all columns for all tables, in the schemas we care about (adjust schema if needed)
SELECT *
FROM
    information_schema.columns
WHERE
    table_schema NOT IN ('pg_catalog', 'information_schema');

-- count of total columns (adjust schema as needed)
SELECT COUNT(*) AS count
FROM
    information_schema.columns
WHERE
    table_schema NOT IN ('pg_catalog', 'information_schema');

-- group by a column, find a common identifier in the top 5 or so
-- exclude id, created_at, updated_at
-- Questions:
-- what's the count of deleted_at relative to all tables?
SELECT column_name, count(*)
FROM
    information_schema.columns
WHERE
    table_schema NOT IN ('pg_catalog', 'information_schema')
AND column_name NOT IN ('id','created_at','updated_at')
    GROUP BY 1
    ORDER BY 2 DESC;


-- foreign key constraints, check constraints etc.
SELECT
    c.oid AS constraint_oid,
    t.oid AS table_oid,
    n.nspname AS schema_name,
    t.relname AS table_name,
    c.conname AS constraint_name,
    c.contype AS constraint_type
FROM
    pg_constraint c
    JOIN pg_class t ON c.conrelid = t.oid
    JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE
    t.relkind = 'r'
AND n.nspname NOT IN ('pg_catalog')
AND c.contype NOT IN ('p'); -- exclude primary key


-- not null column attributes, excluding pg_catalog schema
-- excluding primary key columns like id
-- or auto-generated constraints for columnes like created_at, updated_at
SELECT a.*--COUNT(*) AS not_null_column_count
FROM pg_attribute a
JOIN pg_class t ON a.attrelid = t.oid
JOIN pg_namespace n ON t.relnamespace = n.oid
WHERE a.attnum > 0              -- exclude system columns
  AND NOT a.attisdropped        -- exclude dropped columns
  AND a.attnotnull              -- this is the NOT NULL flag
  AND t.relkind = 'r'          -- regular tables only
AND n.nspname NOT IN ('pg_catalog')
AND a.attname NOT IN ('id','created_at','updated_at');
