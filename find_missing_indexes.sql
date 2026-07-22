-- Find missing indexes (look at seq_scan counts)
-- https://stackoverflow.com/a/12818168/126688
SELECT
  relname                                               AS TableName,
  TO_CHAR(seq_scan, '999,999,999,999')                  AS TotalSeqScan,
  TO_CHAR(idx_scan, '999,999,999,999')                  AS TotalIndexScan,
  TO_CHAR(n_live_tup, '999,999,999,999')                AS TableRows,
  PG_SIZE_PRETTY(PG_RELATION_SIZE(relname::REGCLASS))   AS TableSize
FROM pg_stat_all_tables
WHERE schemaname = 'public' -- change schema name, i.e. 'rideshare' if not 'public'
  -- AND 50 * seq_scan > idx_scan -- more than 2%, add filters to narrow down results
  -- AND n_live_tup > 10000 -- narrow down results for bigger tables
  -- AND pg_relation_size(relname::REGCLASS) > 5000000
ORDER BY seq_scan DESC;


-- missing indexes from GCP docs:
-- Optimize CPU usage
-- https://cloud.google.com/sql/docs/postgres/optimize-cpu-usage
SELECT
    relname,
    idx_scan,
    seq_scan,
    n_live_tup
FROM
    pg_stat_user_tables
WHERE
    seq_scan > 0
ORDER BY
    n_live_tup DESC;
