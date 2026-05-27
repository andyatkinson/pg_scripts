-- for RDS Postgres PGSS
-- Hunting for individual queries that use a lot of IOPS resources
-- We can't directly query it but we can approximate it primarily looking at:
--
-- - shared_blks_read: disk/EBS access
-- - temp_blks_read: Temp files read (sorting, hash joins, materialization exceeding work_mem)
-- - temp_blks_written: Temp files written 
SELECT
    RIGHT (query,
        150), -- for the annotation mainly
    calls,
    shared_blks_read / calls AS shared_reads_per_call,
    temp_blks_read / calls AS temp_reads_per_call,
    temp_blks_written / calls AS temp_writes_per_call
FROM
    pg_stat_statements
WHERE
    calls > 100
    AND ((shared_blks_read / calls > 0)
        OR (temp_blks_read / calls > 0)
        OR (temp_blks_written / calls > 0))
ORDER BY
    (shared_blks_read + temp_blks_read + temp_blks_written) DESC
LIMIT 20;
