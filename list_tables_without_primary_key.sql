-- https://dba.stackexchange.com/a/29933
SELECT tbl.table_schema,
       tbl.table_name
FROM information_schema.tables tbl
WHERE table_type = 'BASE TABLE'
AND table_schema NOT IN ('pg_catalog', 'information_schema')
AND NOT EXISTS (SELECT 1
                FROM information_schema.key_column_usage kcu
                WHERE kcu.table_name = tbl.table_name
                  AND kcu.table_schema = tbl.table_schema);
