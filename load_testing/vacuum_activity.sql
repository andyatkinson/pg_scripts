-- Collect data points
-- Query pg_stat_progress_vacuum
SELECT
  now(),
  r.relname, -- relation name
  p.phase, -- vacuum phase
  p.heap_blks_scanned,
  p.heap_blks_total, -- Total heap pages expected
  p.index_vacuum_count, -- How many indexes have been vacuumed
  p.heap_blks_vacuumed,
  a.state,
  a.query_start,
  a.backend_start,
  a.pid
FROM pg_stat_progress_vacuum p
JOIN pg_class r ON p.relid = r.oid
JOIN pg_stat_activity a ON p.pid = a.pid;

-- Change what's captured
ALTER SYSTEM SET log_autovacuum_min_duration = 0;
SELECT pg_reload_conf();


-- Could store in table:
CREATE TABLE IF NOT EXISTS autovacuum_samples (
  sample_time           timestamptz NOT NULL DEFAULT now(),
  relname               text NOT NULL,           -- relation name
  phase                 text,                    -- vacuum phase
  heap_blks_scanned     bigint,
  heap_blks_total       bigint,
  index_vacuum_count    integer,
  heap_blks_vacuumed    bigint,
  state                 text,
  query_start           timestamptz,
  backend_start         timestamptz,
  pid                   integer NOT NULL
);

INSERT INTO autovacuum_samples (
  sample_time,
  relname,
  phase,
  heap_blks_scanned,
  heap_blks_total,
  index_vacuum_count,
  heap_blks_vacuumed,
  state,
  query_start,
  backend_start,
  pid
)
SELECT
  now(),
  r.relname,
  p.phase,
  p.heap_blks_scanned,
  p.heap_blks_total,
  p.index_vacuum_count,
  p.heap_blks_vacuumed,
  a.state,
  a.query_start,
  a.backend_start,
  a.pid
FROM pg_stat_progress_vacuum p
JOIN pg_class r ON p.relid = r.oid
JOIN pg_stat_activity a ON p.pid = a.pid;
