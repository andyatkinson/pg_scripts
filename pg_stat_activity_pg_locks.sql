SELECT
    psa.pid,
    psa.datname,
    psa.usename,
    psa.query,
    psa.query_start,
    pl.locktype,
    pl.mode,
    pl.granted,
    pl.relation::regclass AS relation_name,
    pl.transactionid,
    pl.virtualtransaction,
    pl.virtualxid,
    pl.pid AS locked_by
FROM
    pg_stat_activity psa
    JOIN pg_locks pl ON psa.pid = pl.pid
ORDER BY
    psa.query_start ASC;
