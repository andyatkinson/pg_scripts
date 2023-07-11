-- Approximate row counts
SELECT relname, relpages, reltuples::numeric, relallvisible, relkind, relnatts, relhassubclass, reloptions, pg_table_size(oid) FROM pg_class WHERE relname='table';

-- Simplified
SELECT reltuples::numeric FROM pg_class WHERE relname='table';

-- select counte('users');
CREATE OR REPLACE FUNCTION counte(tbl text)
RETURNS NUMERIC AS $$
  SELECT reltuples::NUMERIC FROM pg_class WHERE relname=tbl;
$$ LANGUAGE sql;
