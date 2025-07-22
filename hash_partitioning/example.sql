-- partition by HASH working with UUID v1
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE my_table (
  id uuid default uuid_generate_v1(),
  data text,
  PRIMARY KEY (id)
) PARTITION BY HASH (id);

CREATE TABLE my_table_p0 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE my_table_p1 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE my_table_p2 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE my_table_p3 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE my_table_p4 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE my_table_p5 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE my_table_p6 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE my_table_p7 PARTITION OF my_table FOR VALUES WITH (MODULUS 8, REMAINDER 7);

-- Insert one row
INSERT INTO my_table (id, data) VALUES ('c5a92b10-4fdc-11ee-bf3c-3f93b6d34e06', 'something');

-- Insert a bunch of rows
INSERT INTO my_table (id, data)
SELECT uuid_generate_v1(), 'test row ' || gs
FROM generate_series(1, 1000000) gs;



SELECT
  part.relname AS partition_name,
  part.reltuples::bigint AS estimated_rows
FROM
  pg_inherits
  JOIN pg_class parent  ON pg_inherits.inhparent  = parent.oid
  JOIN pg_class part    ON pg_inherits.inhrelid   = part.oid
  JOIN pg_namespace ns  ON part.relnamespace      = ns.oid
WHERE
  parent.relname = 'my_table'
  AND ns.nspname = 'public'
ORDER BY
  partition_name;

--
-- estimated rows:
--
--  partition_name | estimated_rows
-- ----------------+----------------
--  my_table_p0    |         124547
--  my_table_p1    |         124767
--  my_table_p2    |         125131
--  my_table_p3    |         124716
--  my_table_p4    |         125444
--  my_table_p5    |         125392
--  my_table_p6    |         125495
--  my_table_p7    |         124508
-- (8 rows)
