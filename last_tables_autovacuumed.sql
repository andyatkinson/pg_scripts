SELECT relname, last_vacuum, last_autovacuum FROM pg_stat_user_tables where last_autovacuum is not null order by last_autovacuum DESC limit 10;
