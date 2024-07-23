-- Querying pg_wait_sampling_history after
-- enabling the extension

-- Views:
-- pg_wait_sampling_profile
-- pg_wait_sampling_history

SELECT * FROM pg_wait_sampling_history LIMIT 1;
-- pid
-- ts (timestamp)
-- event_type
-- event
-- queryid
--

-- Wait events by process type (event_type)
-- Event types (Client, Activity)
-- Events: ClientRead, AutoVacuumMain
SELECT
    pid,
    event_type,
    event,
    count(*)
FROM
    pg_wait_sampling_history
WHERE
    ts > now() - interval '1 hour'
GROUP BY
    pid,
    event_type,
    event
ORDER BY
    count(*) DESC;


-- https://akorotkov.github.io/blog/2016/03/25/wait_monitoring_9_6/
-- For queries we probably care most about Lock (heavyweight), LWLock (lightweight)
-- For events buffer_content, transactionid


-- Default is 1s, can increase the sampling frequency
pg_wait_sampling.sample_interval = '10ms'

--- Can change the history, default 100
pg_wait_sampling.history_size = 1000
