---https://dba.stackexchange.com/a/39758
SELECT *
FROM pg_stat_activity
WHERE (state = 'idle in transaction')
AND xact_start IS NOT NULL;
