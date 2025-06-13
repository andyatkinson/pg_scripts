#!/bin/bash
#
#
DB_NAME=benchdb
LOGFILE=pgbench_monitor_$(date +%Y%m%d_%H%M%S).log
while true; do {

  echo "===== Sample Time: $(date) ====="

  echo "-- Vacuum Progress --"
  psql -d "$DB_NAME" -At -P expanded=off -c "
  SELECT pid, phase, heap_blks_total, heap_blks_scanned, heap_blks_vacuumed
    FROM pg_stat_progress_vacuum;
  "

  echo "-- LWLock Waits --"
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

  echo "-- Dead Tuples in Benchmark Table --"
    psql -d "$DB_NAME" -At -P expanded=off -c "
      SELECT now(), n_dead_tup, vacuum_count
      FROM pg_stat_user_tables
    "

  echo
} >> "$LOGFILE"

  sleep 2
done & # run in background

while true; do
  echo "Trigger manual vacuum $(date)"
  psql -d "$DB_NAME" -At -P expanded=off -c "
  VACUUM (ANALYZE, VERBOSE) pgxact_burner;
  "
  sleep 10
done & # run in background

wait
