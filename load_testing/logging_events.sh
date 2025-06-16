#!/bin/bash

DB_NAME=benchdb
LOGFILE=pgbench_monitor_$(date +%Y%m%d_%H%M%S).log

loop1() {
  while true; do
    {
      echo "===== Sample: $(date -u +"%Y-%m-%dT%H:%M:%SZ") ====="
      echo "-- System Load --"
      uptime

      # See: vacuum_activity.sql
      echo "-- Vacuum Progress (or none) --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
      SELECT pid, phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed
        FROM pg_stat_progress_vacuum;
      "

      echo "-- LWLock Waits (or none) --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT now() AS sample_time,
               wait_event_type,
               wait_event,
               count(*) AS wait_count
        FROM pg_stat_activity
        WHERE wait_event_type = 'LWLock'
        GROUP BY wait_event_type, wait_event
        ORDER BY wait_count DESC;
      "

      echo "-- Dead Tuples count, vacuum count --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT now(), relname, n_dead_tup, vacuum_count
        FROM pg_stat_user_tables;
      "

      echo "-- hot chain depth for benchmark table --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT
          now(),
          relname,
          n_tup_hot_upd, -- hot updates, we want as many as we can
          n_tup_upd,
          n_tup_ins,
          n_tup_del,
          (n_tup_hot_upd::float / NULLIF(n_tup_upd, 0)) AS hot_update_ratio
        FROM pg_stat_user_tables
        WHERE relname = 'pgxact_burner';
      "

      # See: buffer_cache_eviction_shared_buffers_pressure.sql
      echo "-- buffer cache eviction / cache ratio --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT
            now(),
            blks_read,
            blks_hit,
            (blks_hit::float / NULLIF (blks_hit + blks_read, 0)) AS cache_hit_ratio
        FROM
            pg_stat_database
        WHERE
            datname = current_database();
      "

      # See: buffer_locks_page_access_waits.sql
      echo "-- buffer locks / page access waits --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT
            now(),
            pid,
            usename,
            wait_event_type,
            wait_event,
            query
        FROM
            pg_stat_activity
        WHERE
            wait_event IS NOT NULL
            AND state != 'idle';
      "

      echo "-- pg_stat_io autovacuum worker --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT
            *
        FROM
            pg_stat_io
        WHERE
            backend_type = 'autovacuum worker'
            OR (context = 'vacuum'
                AND (reads <> 0
                    OR writes <> 0
                    OR extends <> 0));
      "

      echo "-- pg_stat_io background writer --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
      SELECT * FROM pg_stat_io
        WHERE backend_type = 'BackgroundWriter';
      "

      # See: pg_stat_slru_sample.sql
      echo "-- pg_stat_slru --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT * FROM pg_stat_slru;
      "

      echo "-- size of PGDATA/pg_xact --"
      du -sh "$PGDATA/pg_xact/"

      echo "-- statements growth --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
      SELECT sum(calls) AS total_statements_executed
        FROM pg_stat_statements;
      "

      # See: page_level_locks.sql
      echo "-- page_level_locks --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT
            now(),
            relation::regclass AS table_name,
            mode,
            COUNT(*) AS lock_count
        FROM
            pg_locks
        WHERE
            relation IS NOT NULL
        GROUP BY
            relation,
            mode;
      "

      echo
    } >> "$LOGFILE" 2>&1

    sleep 2
  done
}

loop2() {
  while true; do
    {
      echo "-- Trigger manual vacuum $(date)--"
      psql -d "$DB_NAME" -At -P expanded=off -c "
      VACUUM (ANALYZE, VERBOSE) pgxact_burner;
      "
      echo
    } >> "$LOGFILE" 2>&1

    sleep 10
  done
}

# Start both loops in background and store their PIDs
loop1 & pid1=$!
loop2 & pid2=$!

# Cleanup on Ctrl+C or termination
cleanup() {
  echo "Cleaning up..."
  kill "$pid1" "$pid2" 2>/dev/null
  wait "$pid1" "$pid2" 2>/dev/null
  echo "Done."
  exit 0
}
trap cleanup SIGINT SIGTERM

# Wait for background loops to finish
wait
