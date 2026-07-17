-- depends on pg_stat_statements
-- Enable source code line level logging: https://andyatkinson.com/source-code-line-numbers-ruby-on-rails-marginalia-query-logs
-- Workflow:
-- 1) Go to source of query
-- 2) Add some restrictions to create smaller working sets
SELECT
    query,
    calls,
    ROWS,
    ROWS::numeric / NULLIF (calls, 0) AS avg_rows_per_call
FROM
    pg_stat_statements
ORDER BY
    ROWS DESC
LIMIT 5;
