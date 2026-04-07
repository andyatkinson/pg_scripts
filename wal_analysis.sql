psql> SELECT pg_current_wal_lsn();
 pg_current_wal_lsn
--------------------
 <!-- WAL LSN -->
(1 row)

-- Collect samples 60 seconds in between
psql> \watch 60

 pg_current_wal_lsn
--------------------
 id1

(every 60s)

 pg_current_wal_lsn
--------------------
 id2

-- Get some quantity in bytes/megabytes
psql> SELECT pg_size_pretty(pg_wal_lsn_diff('id2', 'id1'));
 pg_size_pretty
----------------
 60 MB

-- For this single interval
-- WAL rate = 60 MB / 60 seconds ≈ 1 MB/sec

-- Calculate a rate with more samples, e.g. collect 5 samples, which spans 4 seconds of duration
-- rate = (last - first) / elapsed_seconds
