-- Use this to correlate dead tuple buildup with vacuum timing and CPU load.
SELECT
    now(),
    relname,
    n_dead_tup,
    n_live_tup,
    vacuum_count,
    autovacuum_count
FROM
    pg_stat_user_tables
WHERE
    relname = 'records';

--               now              | relname | n_dead_tup | n_live_tup | vacuum_count | autovacuum_count
-- -------------------------------+---------+------------+------------+--------------+------------------
--  2025-06-11 23:21:41.377559-05 | records |    1000000 |   10000002 |            1 |                0

-- after vacuum

--
--               now              | relname | n_dead_tup | n_live_tup | vacuum_count | autovacuum_count
-- -------------------------------+---------+------------+------------+--------------+------------------
--  2025-06-11 23:22:25.456222-05 | records |          0 |   10000000 |            2 |                0
