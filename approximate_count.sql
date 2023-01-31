-- Approximate row counts
SELECT relname, relpages, reltuples::numeric, relallvisible, relkind, relnatts, relhassubclass, reloptions, pg_table_size(oid) FROM pg_class WHERE relname='table';

-- Simplified
SELECT reltuples::numeric FROM pg_class WHERE relname='table';
