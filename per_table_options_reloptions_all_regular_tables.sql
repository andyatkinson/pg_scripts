-- Credit: ChatGPT
SELECT
    nspname AS schema_name,
    relname AS table_name,
    option_name,
    option_value
FROM
    pg_class c
JOIN
    pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN
    LATERAL pg_options_to_table(reloptions) AS opts(option_name, option_value) ON true
WHERE
    relkind = 'r' -- Only list options for regular tables
    AND nspname NOT IN ('pg_catalog', 'information_schema') -- Exclude system tables
ORDER BY
    nspname,
    relname;


-- E.g. ALTER TABLE trips SET (autovacuum_vacuum_scale_factor = 0.01);

--  schema_name |      table_name      |          option_name           | option_value
-- -------------+----------------------+--------------------------------+--------------
--  rideshare   | ar_internal_metadata |                                |
--  rideshare   | locations            |                                |
--  rideshare   | schema_migrations    |                                |
--  rideshare   | trip_positions       |                                |
--  rideshare   | trip_requests        |                                |
--  rideshare   | trips                | autovacuum_vacuum_scale_factor | 0.01
--  rideshare   | users                | autovacuum_enabled             | false
--  rideshare   | vehicle_reservations |                                |
--  rideshare   | vehicles             |                                |
