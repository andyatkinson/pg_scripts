--- Viewing top tables with lots of dead tuples
SELECT schemaname, relname, n_live_tup, n_dead_tup, last_autovacuum
FROM pg_stat_all_tables
where relname not like 'pg_%'
ORDER BY n_dead_tup
    / (n_live_tup
       * current_setting('autovacuum_vacuum_scale_factor')::float8
          + current_setting('autovacuum_vacuum_threshold')::float8)
     DESC
LIMIT 10;
