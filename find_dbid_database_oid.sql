-- pg_stat_statements uses dbid column
SELECT
    pg_database.oid
FROM
    pg_database
WHERE
    pg_database.datname = 'rideshare_development';
