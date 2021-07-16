-- top updated tables, including HOT updates
-- https://medium.com/nerd-for-tech/postgres-fillfactor-baf3117aca0a
select
   schemaname,
   relname,
   pg_size_pretty(pg_total_relation_size (relname::regclass)) as full_size,
   pg_size_pretty(pg_relation_size(relname::regclass)) as table_size,
   pg_size_pretty(pg_total_relation_size (relname::regclass) - pg_relation_size(relname::regclass)) as index_size,
   n_tup_upd,
   n_tup_hot_upd 
from
   pg_stat_user_tables 
order by
   n_tup_upd desc limit 10;
