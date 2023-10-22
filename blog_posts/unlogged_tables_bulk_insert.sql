\timing -- toggle timing so that it's enabled
CREATE SCHEMA IF NOT EXISTS temp;
CREATE TABLE IF NOT EXISTS temp.tbl (col INTEGER);

-- Takes around 10s on M1 Macbook Air
INSERT INTO temp.tbl (col) VALUES (GENERATE_SERIES(1,10000000));

-- What about unlogged?
-- This takes less than 2 seconds
DROP TABLE temp.tbl;
CREATE UNLOGGED TABLE temp.tbl (col INTEGER);
INSERT INTO temp.tbl (col) VALUES (GENERATE_SERIES(1,10000000));

-- Create destination table
CREATE TABLE IF NOT EXISTS temp.logged_tbl (col INTEGER);

-- Use unlogged table as source table
-- Unlogged table currently has 10 million rows in it
-- In Single CTE, transactionally move the rows from the unlogged
-- table into the logged table
WITH deleted AS (
  DELETE from temp.tbl
  RETURNING *
)
INSERT INTO temp.logged_tbl (col) SELECT * FROM deleted;
