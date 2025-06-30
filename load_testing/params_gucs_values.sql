-- Collect some GUC values related to
-- load testing
SELECT name, setting
FROM pg_settings
WHERE name IN (
  'max_connections',
  'max_worker_processes',
  'max_parallel_workers',
  'max_parallel_workers_per_gather',
  'wal_writer_delay',
  'commit_delay',
  'commit_siblings',
  'synchronous_commit',
  'full_page_writes',
  'autovacuum_max_workers',
  'autovacuum_naptime',
  'autovacuum_vacuum_cost_limit',
  'autovacuum_vacuum_threshold',
  'autovacuum_vacuum_scale_factor',
  'autovacuum_vacuum_cost_delay',
  'autovacuum_work_mem',
  'autovacuum_vacuum_insert_threshold', -- 13+, 1000
  'autovacuum_vacuum_insert_scale_factor', -- 13+, 0.02
  'backend_flush_after',
  'wal_buffers',
  'bgwriter_lru_maxpages',
  'bgwriter_lru_multiplier',
  'log_autovacuum_min_duration',
  'log_min_duration_statement', -- manual vacuums
  'track_io_timing',
  'vacuum_freeze_min_age', -- default 50000000
  'vacuum_freeze_table_age' -- default 150,000,000
);

-- Table storage parameters
-- ALTER TABLE pgxact_burner
-- SET (vacuum_truncate = off);

-- Query table storage parameters
-- SELECT
--   n.nspname AS schema,
--   c.relname AS table,
--   reloptions
-- FROM
--   pg_class c
-- JOIN
--   pg_namespace n ON n.oid = c.relnamespace
-- WHERE
--   c.relkind = 'r'
--   AND reloptions IS NOT NULL
--   AND EXISTS (
--     SELECT 1
--     FROM unnest(c.reloptions) opt
--     WHERE opt LIKE 'vacuum_truncate=%'
--   )
-- ORDER BY 1, 2;
