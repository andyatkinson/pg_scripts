-- For benchdb, using default max_connections=100
-- Exclude my session
-- Only show state IS NOT NULL
-- Filter to 'client backend' to exclude other backends
SELECT usename, state, count(*)
FROM pg_stat_activity
WHERE pid <> pg_backend_pid()  -- exclude your own session
AND state IS NOT NULL         -- exclude NULL states (likely background processes)
AND backend_type = 'client backend'
GROUP BY usename, state
ORDER BY COUNT(*) DESC;
