-- Print something like:
--
-- count,state
-- 5
-- 7,active
-- 3510,idle
select count(*),state FROM pg_stat_activity group by 2;
