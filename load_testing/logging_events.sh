#!/bin/bash

DB_NAME=benchdb
LOGFILE=pgbench_monitor_$(date +%Y%m%d_%H%M%S).log

loop1() {
  while true; do
    {
      echo "===== Sample: $(date) ====="
      echo "-- System Load --"
      uptime

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

      echo "-- Dead Tuples --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT now(), n_dead_tup, vacuum_count
        FROM pg_stat_user_tables;
      "

      echo "-- cache ratio --"
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

      echo "-- pg_stat_slru --"
      psql -d "$DB_NAME" -At -P expanded=off -c "
        SELECT * FROM pg_stat_slru;
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
