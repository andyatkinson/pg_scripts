-- Collect data points
-- Query pg_stat_progress_vacuum
SELECT
  now(),
  pid,
  relid::regclass AS table_name,
  phase,
  heap_blks_total,
  heap_blks_scanned,
  heap_blks_vacuumed,
  index_vacuum_count
FROM pg_stat_progress_vacuum;


-- Could store in table:
CREATE TABLE IF NOT EXISTS vacuum_samples (
  sample_time timestamp,
  pid int,
  table_name text,
  phase text,
  heap_blks_total int,
  heap_blks_scanned int,
  heap_blks_vacuumed int
);

-- Example insert event
INSERT INTO vacuum_samples
SELECT now(), pid, relid::regclass::text, phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed
FROM pg_stat_progress_vacuum;
