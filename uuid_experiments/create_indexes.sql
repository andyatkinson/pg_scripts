\timing on

create index on records (id);      -- records_id_idx
create index on records (uuid_v4); -- records_uuid_v4_idx
create index on records (uuid_v7); -- records_uuid_v7_idx
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
