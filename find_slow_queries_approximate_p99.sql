-- Credit Michael C. / PgMustard
-- https://www.pgmustard.com/blog/approximate-the-p99-of-a-query-with-pgstatstatements
-- Adaptations for different versions of PGSS and adding some exclusions
SELECT
    mean_time::int, --mean_exec_time::int,
    --mean_plan_time::int,
    stddev_time::int, --stddev_exec_time::int,
    -- stddev_plan_time::int,
    -- ((mean_exec_time + mean_plan_time) + 2.33 * sqrt(stddev_exec_time ^ 2 + stddev_plan_time ^ 2))::int AS approx_p99,
    ((mean_time) + 2.33 * sqrt(stddev_time ^ 2 ))::int AS approx_p99,
    calls,
    right(query, 200) -- "query" (this takes only the right-most 200 chars for the query annotation)
FROM
    pg_stat_statements
WHERE
    calls > 1000
AND query NOT LIKE '%INSERT%'
AND query NOT LIKE '%pg_buffercache_usage_counts%'
AND query NOT LIKE '%pg_buffercache_summary%'
ORDER BY
    approx_p99 DESC
LIMIT 50;
