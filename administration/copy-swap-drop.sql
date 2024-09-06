--########
-- SETUP
--########

-- Create testdb
CREATE DATABASE testdb;

\c testdb -- connect to "testdb"

-- events table
CREATE TABLE events (
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
data TEXT,
created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX ON events (data);

-- rows for "events"
INSERT INTO events (data) VALUES ('data');
INSERT INTO events (data) VALUES ('more data');



--########
-- COPY
--########
-- Clone the table structure
CREATE TABLE events_intermediate (
    LIKE events INCLUDING ALL EXCLUDING INDEXES
);

-- Copy a subset of rows
-- Find the first primary key id that's newer than 30 days ago
SELECT id, created_at
FROM events
WHERE created_at > (CURRENT_DATE - INTERVAL '30 days')
LIMIT 1;


-- Copy - Query in batches, up to 1000 at a time
-- Copying rows...
INSERT INTO events_intermediate
OVERRIDING SYSTEM VALUE
SELECT * FROM events WHERE id >= 123456789
ORDER BY id ASC -- the default ordering
LIMIT 1000;

-- Copy in batches - Repeatable statement
WITH t AS (
  SELECT MAX(id) AS max_id
  FROM events_intermediate
)
INSERT INTO events_intermediate
OVERRIDING SYSTEM VALUE
SELECT *
FROM events
WHERE id > (SELECT max_id FROM t)
ORDER BY id
LIMIT 1000;

-- Copying
-- Speed up index creation, increasing to 1GB of system memory
SET maintenance_work_mem = '1GB';

-- Copying - Allow for more parallel maintenance workers
SET max_parallel_maintenance_workers = 4;

-- Copying/index creation - Add time, e.g. 2 hours to provide plenty of time
SET statement_timeout = '120min';

-- Copy - Find index definitions from original table
SELECT indexdef
FROM pg_indexes
WHERE tablename = 'events';

-- Copy - Create indexes for new table
CREATE UNIQUE INDEX events_pkey1_idx ON events_intermediate (id);
CREATE INDEX events_data_idx1 ON events_intermediate (data);

-- Copy - Use index for primary key constraint
ALTER TABLE events_intermediate
ADD CONSTRAINT events_pkey1 PRIMARY KEY
USING INDEX events_pkey1_idx;

-- Copy - Check sequences
SELECT * FROM pg_sequences;

-- Copy - Capture the sequence value plus the raised, as NEW_MINIMUM
SELECT setval('events_intermediate_id_seq', nextval('events_id_seq') + 1000);

-- #################
-- SWAP
-- ##########
BEGIN;
-- Rename original table to be "retired"
ALTER TABLE events RENAME TO events_retired;

-- Rename "intermediate" table to be original table name
ALTER TABLE events_intermediate RENAME TO events;

-- Grab one more batch of any rows committed
-- just before this transaction
WITH t AS (
  SELECT MAX(id) AS max_id
  FROM events_intermediate
)
INSERT INTO events_intermediate
OVERRIDING SYSTEM VALUE
SELECT *
FROM events
WHERE id > (SELECT max_id FROM t)
ORDER BY id
LIMIT 1000;

COMMIT;

-- Swap - one last copy
INSERT INTO events
OVERRIDING SYSTEM VALUE
SELECT * FROM events_retired
WHERE id > (SELECT MAX(id) FROM events);

-- ################
-- ROLLBACK BEGIN
-- ###########
SELECT setval('events_intermediate_id_seq', nextval('events_intermediate_id_seq') + 1000);
BEGIN;
-- the new events table should be sent backward
-- to being the "intermediate" table.
-- The current "retired" table should be promoted to be the main table.
ALTER TABLE events RENAME TO events_intermediate;
-- Make the original jumbo table the main table
ALTER TABLE events_retired RENAME TO events;
COMMIT;

INSERT into events
OVERRIDING SYSTEM VALUE
SELECT *
FROM events_intermediate
WHERE created_at >= (NOW() - INTERVAL '1 hour')
ORDER BY id
ON CONFLICT (id) DO NOTHING;
-- ################
-- ROLLBACK BEGIN
-- ###########


-- #################
-- DROP
-- Warning: Please review everything above before doing this!
-- #################
DROP TABLE events_retired;
