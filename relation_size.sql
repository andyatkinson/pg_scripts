-- size for table or index
SELECT pg_size_pretty(pg_total_relation_size ('rel'));


-- Table name, row count, human readable size
-- Meant for the rideshare sample database
-- and the "users" table
SELECT
    relname AS table_name,
    n_live_tup AS row_count,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM
    pg_stat_user_tables
WHERE
  relname IN ('users')
ORDER BY
    total_size DESC;
