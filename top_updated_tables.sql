-- top updated tables, including HOT updates
-- https://medium.com/nerd-for-tech/postgres-fillfactor-baf3117aca0a
SELECT
    schemaname,
    relname,
    pg_size_pretty(pg_total_relation_size(relname::regclass)) AS full_size,
    pg_size_pretty(pg_relation_size(relname::regclass)) AS table_size,
    pg_size_pretty(pg_total_relation_size(relname::regclass) - pg_relation_size(relname::regclass)) AS index_size,
    n_tup_upd,
    n_tup_hot_upd
FROM
    pg_stat_user_tables
ORDER BY
    n_tup_upd DESC
LIMIT 10;
