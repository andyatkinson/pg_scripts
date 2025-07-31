-- Theories are compaction in toast tables
-- List TOAST tables
SELECT
  toast.relname AS toast_table,
  parent.relname AS parent_table,
  nsp.nspname AS parent_schema
FROM
  pg_class parent
JOIN
  pg_namespace nsp ON parent.relnamespace = nsp.oid
JOIN
  pg_class toast ON toast.oid = parent.reltoastrelid
WHERE
  parent.reltoastrelid <> 0
ORDER BY
  parent_schema, parent.relname;

-- TOAST tables by dead tuple count
SELECT
  nsp.nspname AS parent_schema,
  parent.relname AS parent_table,
  toast.relname AS toast_table,
  stat.n_dead_tup,
  stat.last_autovacuum,
  stat.last_vacuum,
  stat.vacuum_count,
  stat.autovacuum_count
FROM
  pg_class parent
JOIN
  pg_namespace nsp ON parent.relnamespace = nsp.oid
JOIN
  pg_class toast ON toast.oid = parent.reltoastrelid
JOIN
  pg_stat_all_tables stat ON stat.relid = toast.oid
WHERE
  parent.reltoastrelid != 0
  AND stat.n_dead_tup > 0
ORDER BY
  stat.n_dead_tup DESC;
