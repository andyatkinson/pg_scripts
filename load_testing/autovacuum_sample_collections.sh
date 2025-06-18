#!/bin/bash

# Set benchmark table to trigger autovacuum very low


DB_NAME=benchdb
USER="postgres"
HOST="localhost"  # or another hostname
PORT="5432"

psql -U "$USER" -d "$DB_NAME" -h "$HOST" -p "$PORT" -c "
ALTER TABLE pgxact_burner SET (
  autovacuum_vacuum_threshold = 1,
  autovacuum_vacuum_scale_factor = 0.0001
)
"

# check delete churn
psql -U "$USER" -d "$DB_NAME" -h "$HOST" -p "$PORT" -c "
SELECT
  ut.relname,
  c.reltuples::numeric as estimated_count,
  ut.seq_scan,
  ut.seq_tup_read,
  ut.idx_scan,
  ut.n_tup_del AS total_deletes,
  ut.n_live_tup,
  ut.n_dead_tup,
  ut.vacuum_count,
  ut.last_autovacuum
FROM pg_stat_user_tables ut
join pg_class c ON ut.relid = c.oid
WHERE ut.relname = 'pgxact_burner';
"

# Optional: Export PGPASSWORD or use .pgpass for authentication
# export PGPASSWORD="your_password"

# Run insert every 3 seconds
while true; do
  psql -U "$USER" -d "$DB_NAME" -h "$HOST" -p "$PORT" -c "
  select count(*) from pgxact_burner
  "

  psql -U "$USER" -d "$DB_NAME" -h "$HOST" -p "$PORT" -c "
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
  "
  sleep 3
done


# Sample of the sample
# andy@[local]:5432 benchdb# select * from autovacuum_samples ;
# -[ RECORD 1 ]------+------------------------------
# sample_time        | 2025-06-18 17:14:44.957692-05
# relname            | pgxact_burner
# phase              | vacuuming heap
# heap_blks_scanned  | 45971
# heap_blks_total    | 45971
# index_vacuum_count | 1
# heap_blks_vacuumed | 45567
# state              | active
# query_start        | 2025-06-18 17:14:43.934778-05
# backend_start      | 2025-06-18 17:14:43.933613-05
# pid                | 67083
#
