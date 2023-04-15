SELECT relname, reltuples::numeric
FROM pg_class pg, information_schema.tables i
WHERE pg.relname = i.table_name
AND relkind='r'
AND table_schema NOT IN ('pg_catalog', 'information_schema')
AND pg.relname LIKE '<table-name>_%'
ORDER BY pg.relname DESC;
