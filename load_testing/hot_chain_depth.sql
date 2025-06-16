-- Investigate:
-- Low ratio for hot_update_ratio below
-- means long update chains, and more vacuum work
-- Currently scoped to a single table, here it's "pgxact_burner"
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
