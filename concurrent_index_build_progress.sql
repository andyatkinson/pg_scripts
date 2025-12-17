-- Check the status of the index build
SELECT
  now()::TIME(0),
  a.query,
  p.phase,
  round(p.blocks_done / p.blocks_total::numeric * 100, 2) AS "% done",
  p.blocks_total,
  p.blocks_done,
  p.tuples_total,
  p.tuples_done,
  ai.schemaname,
  ai.relname,
  ai.indexrelname
FROM pg_stat_progress_create_index p
LEFT JOIN pg_stat_all_indexes ai on ai.relid = p.relid AND ai.indexrelid = p.index_relid;
