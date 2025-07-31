WITH columns AS (
    SELECT
        table_schema,
        COUNT(*) AS column_count
    FROM
        information_schema.columns
    WHERE
        table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY
        table_schema
),
not_nulls AS (
    SELECT
        table_schema,
        COUNT(*) AS not_null_count
    FROM
        information_schema.columns
    WHERE
        is_nullable = 'NO'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY
        table_schema
),
constraints AS (
    SELECT
        table_schema,
        COUNT(*) FILTER (WHERE constraint_type = 'PRIMARY KEY') AS pk_count,
        COUNT(*) FILTER (WHERE constraint_type = 'FOREIGN KEY') AS fk_count,
        COUNT(*) FILTER (WHERE constraint_type = 'UNIQUE') AS unique_count,
        COUNT(*) FILTER (WHERE constraint_type = 'CHECK') AS check_count
    FROM
        information_schema.table_constraints
    WHERE
        table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY
        table_schema
),
tables AS (
    SELECT
        table_schema,
        COUNT(*) AS table_count
    FROM
        information_schema.tables
    WHERE
        table_type = 'BASE TABLE'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY
        table_schema
)
SELECT
    c.table_schema,
    t.table_count,
    c.column_count,
    n.not_null_count,
    ct.pk_count,
    ct.fk_count,
    ct.unique_count,
    ct.check_count,
    -- Constraint per column ratios
    ROUND(n.not_null_count::numeric / NULLIF (c.column_count, 0), 2) AS not_null_ratio,
    ROUND(ct.pk_count::numeric / NULLIF (t.table_count, 0), 2) AS pk_per_table,
    ROUND(ct.fk_count::numeric / NULLIF (t.table_count, 0), 2) AS fk_per_table,
    ROUND(ct.check_count::numeric / NULLIF (c.column_count, 0), 2) AS check_per_column,
    ROUND((ct.pk_count + ct.fk_count + ct.unique_count + ct.check_count)::numeric / NULLIF (c.column_count, 0), 2) AS total_constraints_per_column
FROM
    columns c
    JOIN not_nulls n ON c.table_schema = n.table_schema
    JOIN constraints ct ON c.table_schema = ct.table_schema
    JOIN tables t ON c.table_schema = t.table_schema
ORDER BY
    total_constraints_per_column DESC;


-- Example result:
-- -[ RECORD 1 ]----------------+----------
-- table_schema                 | rideshare
-- table_count                  | 10
-- column_count                 | 65
-- not_null_count               | 54
-- pk_count                     | 10
-- fk_count                     | 8
-- unique_count                 | 0
-- check_count                  | 57
-- not_null_ratio               | 0.83
-- pk_per_table                 | 1.00
-- fk_per_table                 | 0.80
-- check_per_column             | 0.88
-- total_constraints_per_column | 1.15
