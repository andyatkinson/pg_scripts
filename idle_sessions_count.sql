-- Print something like:
--
-- count,state
-- 5
-- 7,active
-- 3510,idle
SELECT
  count(*),
  state
FROM pg_stat_activity
GROUP BY 2;
