-- https://dataedo.com/kb/query/postgresql/list-10-largest-tables
-- List 10 largest tables
SELECT
  schemaname AS table_schema,
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
  pg_size_pretty(pg_relation_size(relid)) AS data_size,
  pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS external_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY
  pg_total_relation_size(relid) DESC,
  pg_relation_size(relid) DESC
LIMIT 10;
