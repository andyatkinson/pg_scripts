\timing on

create index on records (id);
create index on records (uuid_v4);
create index on records (uuid_v7);
vacuum analyze records;

SELECT
    relname,
    pg_size_pretty(pg_relation_size(oid)),
    pg_prewarm (oid)
FROM
    pg_class
WHERE
    relname LIKE 'records%';


EXPLAIN (BUFFERS, ANALYZE, TIMING OFF) SELECT COUNT(id) FROM records;
EXPLAIN (BUFFERS, ANALYZE, TIMING OFF) SELECT COUNT(uuid_v4) FROM records;
