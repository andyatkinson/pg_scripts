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
  'backend_flush_after',
  'wal_buffers',
  'bgwriter_lru_maxpages',
  'bgwriter_lru_multiplier'
);
