---https://dba.stackexchange.com/a/39758
SELECT *
FROM pg_stat_activity
WHERE (state = 'idle in transaction')
AND xact_start IS NOT NULL;

-- More fields, using age() function to find
-- older transactions
SELECT
    pid,
    usename,
    state,
    query,
    age(clock_timestamp(), query_start) AS idle_duration,
    client_addr
FROM
    pg_stat_activity
WHERE
    state = 'idle in transaction'
    AND age(clock_timestamp(), query_start) > interval '5 minutes'; -- Adjust the interval as needed

