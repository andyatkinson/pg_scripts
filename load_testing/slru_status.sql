-- https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-SLRU-VIEW

-- multi-transaction (nested transactions)
SELECT * FROM pg_stat_slru WHERE name = 'MultiXactMember' OR name = 'MultiXactOffset';

-- check out lwlock.c
-- for "Xact"
SELECT * FROM pg_stat_slru;

-- multixact age for all databases
-- For multi-transaction, nested transactions aka subtransactions,
-- use of "savepoint" etc.
SELECT
    datname,
    age(datminmxid) AS multixact_age
FROM
    pg_database
ORDER BY
    multixact_age DESC;

