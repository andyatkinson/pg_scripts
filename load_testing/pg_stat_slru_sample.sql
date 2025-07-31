-- https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-SLRU-VIEW

-- "hits" and "reads" are like the buffer cache, either in the SLRU or not

--  name         | Xact
--  blks_zeroed  | 427
--  blks_hit     | 28488795
--  blks_read    | 27
--  blks_written | 404
--  blks_exists  | 0
--  flushes      | 509
--  truncates    | 0
--  stats_reset  | 2024-11-19 09:52:33.506794-06
--
--  Row:
--  Xact|427|28488795|27|404|0|509|0|2024-11-19 09:52:33.506794-06
SELECT * FROM pg_stat_slru;
