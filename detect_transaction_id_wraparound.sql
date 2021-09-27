-- TXID is a global value
--
-- Goal: Detect tables that will likely be
-- force vacuummed soon due to transaction ID wraparound
--
-- https://blog.crunchydata.com/blog/managing-transaction-id-wraparound-in-postgresql
WITH max_age AS (
    SELECT 2000000000 as max_old_xid
        , setting AS autovacuum_freeze_max_age
        FROM pg_catalog.pg_settings
        WHERE name = 'autovacuum_freeze_max_age' )
, per_database_stats AS (
    SELECT datname
        , m.max_old_xid::int
        , m.autovacuum_freeze_max_age::int
        , age(d.datfrozenxid) AS oldest_current_xid
    FROM pg_catalog.pg_database d
    JOIN max_age m ON (true)
    WHERE d.datallowconn )
SELECT max(oldest_current_xid) AS oldest_current_xid
    , max(ROUND(100*(oldest_current_xid/max_old_xid::float))) AS percent_towards_wraparound
    , max(ROUND(100*(oldest_current_xid/autovacuum_freeze_max_age::float))) AS percent_towards_emergency_autovac
FROM per_database_stats;


-- Using autovacuum_freeze_max_age default value of 200 million
-- Script below checks for 190 million
-- credit: David R.
--
-- Potential fix is to: `vacuum freeze <table>` the specific tables
--
select relname,age(relfrozenxid),pg_size_pretty(pg_relation_size(oid)) as size from pg_Class where age(relfrozenxid) > 190000000 and relkind = 'r';
