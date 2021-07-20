-- https://stackoverflow.com/a/12818168/126688
SELECT
  relname                                               AS TableName,
  to_char(seq_scan, '999,999,999,999')                  AS TotalSeqScan,
  to_char(idx_scan, '999,999,999,999')                  AS TotalIndexScan,
  to_char(n_live_tup, '999,999,999,999')                AS TableRows,
  pg_size_pretty(pg_relation_size(relname :: regclass)) AS TableSize
FROM pg_stat_all_tables
WHERE schemaname = 'public'
      AND 50 * seq_scan > idx_scan -- more than 2%
      AND n_live_tup > 10000
      AND pg_relation_size(relname :: regclass) > 5000000
ORDER BY relname ASC;
